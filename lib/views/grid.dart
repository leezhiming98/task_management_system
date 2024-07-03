import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:task_management_system/services/api.dart';
import '../models/task.dart';
import '../models/user.dart';
import 'toast.dart';
import 'loading.dart';

class Grid extends StatefulWidget {
  final List<Task> tasks;
  final List<User> users;

  const Grid({super.key, required this.tasks, required this.users});

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  /// STATES
  late List<Task> allTasks;
  late List<Task> initTasks; // filtering
  late List<Task> filteredTasks; // filtering
  late List<User> users;
  bool loading = false;
  int currentPage = 0; // pagination
  int pageSize = 15; // pagination
  bool sort = false; // sorting
  int index = 0; // sorting

  /// CONTROLLERS
  /// pagination
  final ScrollController _scrollController = ScrollController();

  ///  0 - 5  for filtering
  ///  6      for adding
  ///  7      for searching assignee
  final List<TextEditingController> _textController =
      List.generate(8, (i) => TextEditingController());

  ///  adding
  final FocusNode _focusNode = FocusNode();

  /// TABLE INFORMATION
  List<Map<String, dynamic>> columnDesc = [
    {
      "index": 0,
      "header": "Title",
      "width": 160,
      "identifier": "title",
      "filterable": true,
    },
    {
      "index": 1,
      "header": "Description",
      "width": 520,
      "identifier": "description",
      "filterable": true,
    },
    {
      "index": 2,
      "header": "Progress",
      "width": 100,
      "identifier": "progress",
      "filterable": false,
    },
    {
      "index": 3,
      "header": "Assignee",
      "width": 120,
      "identifier": "assignee",
      "filterable": true,
    },
    {
      "index": 4,
      "header": "Period",
      "width": 160,
      "identifier": "formattedDate",
      "filterable": true,
    },
    {
      "index": 5,
      "header": "Urgency",
      "width": 120,
      "identifier": "urgencyName",
      "filterable": true,
    }
  ];

  Map<String, String> filterQuery = {
    "title": "",
    "description": "",
    "assignee": "",
    "formattedDate": "",
    "urgencyName": ""
  };

  Map<String, dynamic> editableValue = {
    "position": null,
    "title": "",
    "description": "",
    "progress": null
  };

  DataCell gridFilter(
      {required double columnWidth,
      required int columnIndex,
      required String header,
      required String filterKey,
      required bool filterable}) {
    return DataCell(
      filterable
          ? SizedBox(
              width: columnWidth,
              child: TextField(
                controller: _textController[columnIndex],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Filter $header ...",
                  hintStyle: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                onChanged: (text) {
                  setState(() {
                    filterQuery[filterKey] = text;
                  });
                  onFilterColumn(query: filterQuery);
                },
              ),
            )
          : SizedBox(
              width: columnWidth,
            ),
    );
  }

  /// TABLE FUNCTIONS
  void onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      index = columnIndex;
      sort = ascending;
    });

    switch (columnIndex) {
      case 0:
        ascending
            ? filteredTasks.sort((a, b) => a.title.compareTo(b.title))
            : filteredTasks.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 1:
        ascending
            ? filteredTasks
                .sort((a, b) => a.description.compareTo(b.description))
            : filteredTasks
                .sort((a, b) => b.description.compareTo(a.description));
        break;
      case 2:
        ascending
            ? filteredTasks.sort((a, b) => a.progress.compareTo(b.progress))
            : filteredTasks.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 3:
        ascending
            ? filteredTasks
                .sort((a, b) => a.assigneeUserId.compareTo(b.assigneeUserId))
            : filteredTasks
                .sort((a, b) => b.assigneeUserId.compareTo(a.assigneeUserId));
        break;
      case 4:
        ascending
            ? filteredTasks
                .sort((a, b) => a.formattedDate!.compareTo(b.formattedDate!))
            : filteredTasks
                .sort((a, b) => b.formattedDate!.compareTo(a.formattedDate!));
        break;
      case 5:
        ascending
            ? filteredTasks
                .sort((a, b) => a.urgencyName.compareTo(b.urgencyName))
            : filteredTasks
                .sort((a, b) => b.urgencyName.compareTo(a.urgencyName));
        break;
      default:
        break;
    }
  }

  void onFilterColumn(
      {required Map<String, String> query, bool clear = false}) {
    query.forEach((key, value) => query[key] = value.toLowerCase());

    List<Task> temp = [...initTasks];

    if (query["title"]!.isNotEmpty) {
      temp = temp
          .where((t) => t.title.toLowerCase().startsWith(query["title"]!))
          .toList();
    }
    if (query["description"]!.isNotEmpty) {
      temp = temp
          .where((t) =>
              t.description.toLowerCase().startsWith(query["description"]!))
          .toList();
    }
    if (query["assignee"]!.isNotEmpty) {
      var assigneeIds = users
          .where((u) => u.name.toLowerCase().startsWith(query["assignee"]!))
          .map((u) => int.parse(u.id))
          .toList();
      temp = temp.where((t) => assigneeIds.contains(t.assigneeUserId)).toList();
    }
    if (query["formattedDate"]!.isNotEmpty) {
      temp = temp
          .where((t) => t.formattedDate!.startsWith(query["formattedDate"]!))
          .toList();
    }
    if (query["urgencyName"]!.isNotEmpty) {
      temp = temp
          .where((t) =>
              t.urgencyName.toLowerCase().startsWith(query["urgencyName"]!))
          .toList();
    }
    if (clear) {
      for (int i = 0; i <= 5; i++) {
        _textController[i].clear();
      }
    }
    setState(() {
      filteredTasks = temp;
    });
  }

  void onPaginate() {
    if (initTasks.length != allTasks.length) {
      setState(() {
        loading = true;
      });

      // stimulate loading delay
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          currentPage += 1;
          initTasks = allTasks.take(currentPage * pageSize).toList();
          filteredTasks = [...initTasks];
        });
        onFilterColumn(query: filterQuery);
        setState(() {
          loading = false;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        toast(
            message: "All tasks have been successfully loaded!",
            width: 400,
            isSuccess: true,
            duration: 3),
      );
    }
  }

  void setEditableValues(String id) {
    int position = allTasks.indexWhere((t) => t.id == id);
    if (editableValue["position"] == null ||
        editableValue["position"] != position) {
      setState(() {
        editableValue["position"] = position;
        editableValue["title"] = allTasks[position].title;
        editableValue["description"] = allTasks[position].description;
        editableValue["progress"] = allTasks[position].progress;
      });
    }
  }

  bool validateEditableValues() {
    if (editableValue["title"].length <= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        toast(
            message: "Title Must Exceed 5 Characters !",
            width: 350,
            isSuccess: false,
            duration: 3),
      );
      return false;
    }
    if (editableValue["description"].length <= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        toast(
            message: "Description Must Exceed 5 Characters !",
            width: 400,
            isSuccess: false,
            duration: 3),
      );
      return false;
    }
    if (editableValue["progress"] == null || editableValue["progress"] > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        toast(
            message: "Progress Must Be From 0 To 100 !",
            width: 350,
            isSuccess: false,
            duration: 3),
      );
      return false;
    }
    return true;
  }

  void addCell(String title) async {
    setState(() {
      loading = true;
    });

    DateTime today = DateTime.now();
    Task task = Task(
      id: "",
      createdAt: today,
      assigneeUserId: 0,
      title: title,
      description: "Placeholder Description ...",
      startDate: today,
      endDate: today.add(const Duration(days: 365)),
      defaultPosition: 1,
      urgencyName: "Low",
      progress: 0,
      isEditing: false,
    );

    await addTask(task).then((data) {
      if (data.id.isNotEmpty) {
        setState(() {
          allTasks.insert(0, data);
          initTasks.insert(0, data);
          filteredTasks.insert(0, data);
        });
        _textController[6].clear();
        ScaffoldMessenger.of(context).showSnackBar(
          toast(
              message: "Task has been successfully added!",
              width: 350,
              isSuccess: true,
              duration: 3),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          toast(
              message: "Failed To Add or Duplicate Task!",
              width: 400,
              isSuccess: false,
              duration: 3),
        );
      }
      setState(() {
        loading = false;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        toast(message: "$error", width: 400, isSuccess: false, duration: 3),
      );
      setState(() {
        loading = false;
      });
    });
  }

  void updateCell(String id, Task updated, int position) async {
    setState(() {
      loading = true;
    });

    await updateTask(id, updated).then((data) {
      if (data.id.isNotEmpty) {
        setState(() {
          allTasks[position] = data;
          initTasks[position] = data;
          filteredTasks[position] = data;
          for (var t in filteredTasks) {
            t.isEditing = false;
          }
        });
        _textController[7].clear();
        ScaffoldMessenger.of(context).showSnackBar(
          toast(
              message: "Task has been successfully updated!",
              width: 350,
              isSuccess: true,
              duration: 3),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          toast(
              message: "Failed To Update Task!",
              width: 350,
              isSuccess: false,
              duration: 3),
        );
      }
      setState(() {
        loading = false;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        toast(message: "$error", width: 350, isSuccess: false, duration: 3),
      );
      setState(() {
        loading = false;
      });
    });
  }

  void duplicateCell(String id) async {
    setState(() {
      loading = true;
    });

    int position = allTasks.indexWhere((t) => t.id == id);
    Task clone = allTasks[position].copy();
    clone.title = clone.title.startsWith("(Cloned)")
        ? clone.title
        : "(Cloned) ${clone.title}";

    await addTask(clone).then((data) {
      if (data.id.isNotEmpty) {
        setState(() {
          allTasks.insert(position + 1, data);
          initTasks.insert(position + 1, data);
          filteredTasks.insert(position + 1, data);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          toast(
              message: "Task has been successfully duplicated!",
              width: 400,
              isSuccess: true,
              duration: 3),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          toast(
              message: "Failed To Add or Duplicate Task!",
              width: 400,
              isSuccess: false,
              duration: 3),
        );
      }
      setState(() {
        loading = false;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        toast(message: "$error", width: 400, isSuccess: false, duration: 3),
      );
      setState(() {
        loading = false;
      });
    });
  }

  void deleteCell(String id) async {
    setState(() {
      loading = true;
    });

    await deleteTask(id).then((success) {
      if (success) {
        setState(() {
          allTasks.removeWhere((t) => t.id == id);
          initTasks.removeWhere((t) => t.id == id);
          filteredTasks.removeWhere((t) => t.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          toast(
              message: "Task has been successfully deleted!",
              width: 350,
              isSuccess: true,
              duration: 3),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          toast(
              message: "Failed To Delete Task!",
              width: 350,
              isSuccess: false,
              duration: 3),
        );
      }
      setState(() {
        loading = false;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        toast(message: "$error", width: 350, isSuccess: false, duration: 3),
      );
      setState(() {
        loading = false;
      });
    });
  }

  /// INITSTATE & DISPOSE
  @override
  void initState() {
    super.initState();
    allTasks = widget.tasks;
    users = widget.users;

    // pagination
    currentPage += 1;
    initTasks = allTasks.take(currentPage * pageSize).toList();
    filteredTasks = [...initTasks];

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        onPaginate();
      }
    });

    // adding
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          for (var t in filteredTasks) {
            t.isEditing = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var c in _textController) {
      c.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  /// WIDGET
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double gridLRMargin = screenSize.width * 0.08;
    final double gridTBMargin = screenSize.height * 0.06;
    final double gridWidth = screenSize.width - gridLRMargin * 2;

    return Stack(
      children: [
        /// TAP REGION
        TapRegion(
          onTapOutside: (event) {
            setState(() {
              for (var t in filteredTasks) {
                t.isEditing = false;
              }
            });
          },
          child: Container(
            width: gridWidth,
            margin: EdgeInsets.symmetric(
              horizontal: gridLRMargin,
              vertical: gridTBMargin,
            ),
            child: Column(
              children: [
                /// HORIZONTAL SCROLLING
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        /// TABLE STICKY HEADER & FILTER
                        DataTable(
                          sortAscending: sort,
                          sortColumnIndex: index,

                          /// COLUMN
                          columns: [
                            /// HEADER
                            ...List.generate(
                              columnDesc.length,
                              (index) => DataColumn(
                                label: Text(
                                  columnDesc[index]["header"],
                                ),
                                onSort: (columnIndex, ascending) {
                                  onSortColumn(columnIndex, ascending);
                                },
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                "",
                              ),
                            ),
                          ],

                          /// ROW
                          rows: [
                            /// FILTER
                            DataRow(
                              cells: [
                                ...columnDesc.map(
                                  (c) => gridFilter(
                                      columnWidth: c["width"],
                                      columnIndex: c["index"],
                                      header: c["header"],
                                      filterKey: c["identifier"],
                                      filterable: c["filterable"]),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 48,
                                    child: Center(
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            filterQuery.forEach((key, value) =>
                                                filterQuery[key] = "");
                                          });
                                          onFilterColumn(
                                              query: filterQuery, clear: true);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        /// DATA TABLE
                        Expanded(
                          /// VERTICAL SCROLLING
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.vertical,

                            /// TABLE
                            child: DataTable(
                              /// COLUMN
                              headingRowHeight: 0,
                              columns: [
                                /// EMPTY HEADER
                                ...List.generate(
                                    columnDesc.length + 1,
                                    (index) =>
                                        const DataColumn(label: Text(""))),
                              ],

                              /// ROW
                              rows: [
                                /// DATA
                                ...filteredTasks.map(
                                  (task) => DataRow(
                                    color: task.isEditing
                                        ? WidgetStateProperty.all(
                                            Colors.black.withOpacity(0.1))
                                        : null,
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: columnDesc[0]["width"],
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 160),
                                            child: !task.isEditing
                                                ? Text(
                                                    task.title,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                :

                                                /// EDITABLE TEXT INPUT
                                                TextFormField(
                                                    initialValue: task.title,
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                    ),
                                                    onChanged: (text) {
                                                      setEditableValues(
                                                          task.id);
                                                      setState(() {
                                                        editableValue["title"] =
                                                            text;
                                                      });
                                                    },
                                                    onFieldSubmitted: (text) {
                                                      setEditableValues(
                                                          task.id);
                                                      var validated =
                                                          validateEditableValues();
                                                      if (validated) {
                                                        Task updated = allTasks[
                                                                editableValue[
                                                                    "position"]]
                                                            .copy();
                                                        updated.title =
                                                            editableValue[
                                                                "title"];
                                                        updated.description =
                                                            editableValue[
                                                                "description"];
                                                        updated.progress =
                                                            editableValue[
                                                                "progress"];
                                                        updateCell(
                                                            task.id,
                                                            updated,
                                                            editableValue[
                                                                "position"]);
                                                      }
                                                    },
                                                  ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            for (var t in filteredTasks) {
                                              t.isEditing = false;
                                            }
                                            task.isEditing = true;
                                          });
                                        },
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: columnDesc[1]["width"],
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 520),
                                            child: !task.isEditing
                                                ? Text(
                                                    task.description,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                :

                                                /// EDITABLE TEXT INPUT
                                                TextFormField(
                                                    initialValue:
                                                        task.description,
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                    ),
                                                    onChanged: (text) {
                                                      setEditableValues(
                                                          task.id);
                                                      setState(() {
                                                        editableValue[
                                                                "description"] =
                                                            text;
                                                      });
                                                    },
                                                    onFieldSubmitted: (text) {
                                                      setEditableValues(
                                                          task.id);
                                                      var validated =
                                                          validateEditableValues();
                                                      if (validated) {
                                                        Task updated = allTasks[
                                                                editableValue[
                                                                    "position"]]
                                                            .copy();
                                                        updated.title =
                                                            editableValue[
                                                                "title"];
                                                        updated.description =
                                                            editableValue[
                                                                "description"];
                                                        updated.progress =
                                                            editableValue[
                                                                "progress"];
                                                        updateCell(
                                                            task.id,
                                                            updated,
                                                            editableValue[
                                                                "position"]);
                                                      }
                                                    },
                                                  ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            for (var t in filteredTasks) {
                                              t.isEditing = false;
                                            }
                                            task.isEditing = true;
                                          });
                                        },
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: columnDesc[2]["width"],
                                          child: Center(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 100),
                                              child: !task.isEditing
                                                  ? Tooltip(
                                                      message:
                                                          "${task.progress}%",
                                                      preferBelow: false,
                                                      verticalOffset: -13,
                                                      child:
                                                          LinearPercentIndicator(
                                                        percent:
                                                            task.progress / 100,
                                                        progressColor: task
                                                                    .progress >=
                                                                50
                                                            ? Colors.green[400]
                                                            : Colors.red[400],
                                                        lineHeight: 15,
                                                        width: 100,
                                                      ),
                                                    )
                                                  :

                                                  /// EDITABLE TEXT INPUT
                                                  TextFormField(
                                                      initialValue:
                                                          "${task.progress}",
                                                      keyboardType:
                                                          TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly
                                                      ],
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                      onChanged: (text) {
                                                        setEditableValues(
                                                            task.id);
                                                        setState(() {
                                                          editableValue[
                                                              "progress"] = text
                                                                  .isNotEmpty
                                                              ? int.parse(text)
                                                              : null;
                                                        });
                                                      },
                                                      onFieldSubmitted: (text) {
                                                        setEditableValues(
                                                            task.id);
                                                        var validated =
                                                            validateEditableValues();
                                                        if (validated) {
                                                          Task updated = allTasks[
                                                                  editableValue[
                                                                      "position"]]
                                                              .copy();
                                                          updated.title =
                                                              editableValue[
                                                                  "title"];
                                                          updated.description =
                                                              editableValue[
                                                                  "description"];
                                                          updated.progress =
                                                              editableValue[
                                                                  "progress"];
                                                          updateCell(
                                                              task.id,
                                                              updated,
                                                              editableValue[
                                                                  "position"]);
                                                        }
                                                      },
                                                    ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            for (var t in filteredTasks) {
                                              t.isEditing = false;
                                            }
                                            task.isEditing = true;
                                          });
                                        },
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: columnDesc[3]["width"],
                                          child: task.assigneeUserId > 0
                                              ? Center(
                                                  child: Tooltip(
                                                    message: users
                                                        .firstWhere((u) =>
                                                            int.parse(u.id) ==
                                                            task.assigneeUserId)
                                                        .name,
                                                    preferBelow: false,
                                                    verticalOffset: -13,
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundImage:
                                                          NetworkImage(
                                                        users
                                                            .firstWhere((u) =>
                                                                int.parse(
                                                                    u.id) ==
                                                                task.assigneeUserId)
                                                            .avatar,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const Center(),
                                        ),

                                        /// DIALOG
                                        onTap: () {
                                          setState(() {
                                            for (var t in filteredTasks) {
                                              t.isEditing = false;
                                            }
                                          });
                                          showAssigneeDialog(context, task);
                                        },
                                      ),
                                      DataCell(
                                          SizedBox(
                                            width: columnDesc[4]["width"],
                                            child: Center(
                                              child: Text(
                                                task.formattedDate!,
                                                maxLines: 1,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          ),

                                          /// DIALOG
                                          onTap: () {
                                        setState(() {
                                          for (var t in filteredTasks) {
                                            t.isEditing = false;
                                          }
                                        });
                                        showPeriodDialog(context, task);
                                      }),
                                      DataCell(
                                        SizedBox(
                                          width: columnDesc[5]["width"],
                                          child: Center(
                                            child: Text(
                                              task.urgencyName,
                                              maxLines: 1,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ),

                                        /// DIALOG
                                        onTap: () {
                                          setState(() {
                                            for (var t in filteredTasks) {
                                              t.isEditing = false;
                                            }
                                          });
                                          showUrgencyDialog(context, task);
                                        },
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 48,
                                          child: Center(
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.more_vert,
                                              ),

                                              /// DIALOG
                                              onPressed: () {
                                                setState(() {
                                                  for (var t in filteredTasks) {
                                                    t.isEditing = false;
                                                  }
                                                });
                                                showMoreDialog(context, task);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    /// ADD TEXT INPUT
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _textController[6],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 25),
                          border: InputBorder.none,
                          hintText: "Add New Task ...",
                          hintStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        onSubmitted: (text) {
                          if (text.length <= 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              toast(
                                  message:
                                      "New Title Must Exceed 5 Characters !",
                                  width: 400,
                                  isSuccess: false,
                                  duration: 3),
                            );
                          } else {
                            addCell(text);
                          }
                        },
                      ),
                    ),

                    /// PAGINATE BUTTON
                    TextButton(
                      onPressed: () {
                        onPaginate();
                      },
                      child: Text(
                        "Load More",
                        style: TextStyle(
                          color: Colors.green[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        /// SPINNER
        if (loading) const Loading(),
      ],
    );
  }

  Future<dynamic> showMoreDialog(BuildContext context, Task task) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Actions",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                duplicateCell(task.id);
                Navigator.of(context).pop();
              },
              child: Text(
                "Clone",
                style: TextStyle(
                  color: Colors.green[400],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                deleteCell(task.id);
                Navigator.of(context).pop();
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red[400],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> showUrgencyDialog(BuildContext context, Task task) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          String dropdownValue = task.urgencyName;

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                "Urgency",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton(
                    value: dropdownValue,
                    onChanged: (value) {
                      setState(() {
                        dropdownValue = value!;
                      });

                      int position =
                          allTasks.indexWhere((t) => t.id == task.id);
                      Task updated = allTasks[position].copy();
                      updated.urgencyName = dropdownValue;
                      updateCell(task.id, updated, position);
                      Navigator.of(context).pop();
                    },
                    items: ["High", "Medium", "Low"].map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          });
        });
  }

  Future<dynamic> showPeriodDialog(BuildContext context, Task task) async {
    DateTimeRange? period = await showDateRangePicker(
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 495,
                ),
                child: child,
              ),
            ),
          ],
        );
      },
      context: context,
      initialDateRange: DateTimeRange(start: task.startDate, end: task.endDate),
      firstDate: DateTime(2023),
      lastDate: DateTime(2028),
      helpText: "Period",
      cancelText: "Cancel",
      confirmText: "Save",
      saveText: "Save",
    );

    if (period != null) {
      int position = allTasks.indexWhere((t) => t.id == task.id);
      Task updated = allTasks[position].copy();
      updated.startDate = period.start;
      updated.endDate = period.end;
      updateCell(task.id, updated, position);
    }
  }

  Future<dynamic> showAssigneeDialog(BuildContext context, Task task) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        List<User> filteredAvatars = [...users];

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                "Assignee",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    child: TextField(
                      controller: _textController[7],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search Assignee ...",
                        hintStyle: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      onChanged: (text) {
                        var query = text.toLowerCase();
                        List<User> temp = [...users];

                        if (query.isNotEmpty) {
                          temp = temp
                              .where(
                                  (u) => u.name.toLowerCase().startsWith(query))
                              .toList();
                        }
                        setState(() {
                          filteredAvatars = temp;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 230,
                    height: 160,
                    child: filteredAvatars.isNotEmpty
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            itemCount: filteredAvatars.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Center(
                                child: InkWell(
                                  child: Tooltip(
                                    message: filteredAvatars[index].name,
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        filteredAvatars[index].avatar,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    int position = allTasks
                                        .indexWhere((t) => t.id == task.id);
                                    Task updated = allTasks[position].copy();
                                    updated.assigneeUserId =
                                        int.parse(filteredAvatars[index].id);
                                    updateCell(task.id, updated, position);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            },
                          )
                        : const Center(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _textController[7].clear();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
