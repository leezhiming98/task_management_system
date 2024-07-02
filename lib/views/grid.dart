import 'package:flutter/material.dart';
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
  late List<Task> initTasks; // for filtering use
  late List<Task> filteredTasks;
  late List<User> users;
  int currentPage = 0;
  int pageSize = 15;
  bool loading = false;
  bool sort = false;
  int index = 0;

  /// CONTROLLERS
  final ScrollController _scrollController = ScrollController();
  final List<TextEditingController> _textController =
      List.generate(8, (i) => TextEditingController());

  /// TABLE INFORMATION
  List<Map<String, dynamic>> columnDesc = [
    {
      "position": 0,
      "header": "Title",
      "width": 160,
      "identifier": "title",
      "filterable": true,
    },
    {
      "position": 1,
      "header": "Description",
      "width": 520,
      "identifier": "description",
      "filterable": true,
    },
    {
      "position": 2,
      "header": "Progress",
      "width": 100,
      "identifier": "progress",
      "filterable": false,
    },
    {
      "position": 3,
      "header": "Assignee",
      "width": 120,
      "identifier": "assignee",
      "filterable": true,
    },
    {
      "position": 4,
      "header": "Period",
      "width": 160,
      "identifier": "formattedDate",
      "filterable": true,
    },
    {
      "position": 5,
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

    currentPage += 1;
    initTasks = allTasks.take(currentPage * pageSize).toList();
    filteredTasks = [...initTasks];

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        onPaginate();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var c in _textController) {
      c.dispose();
    }
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
        Container(
          width: gridWidth,
          margin: EdgeInsets.symmetric(
            horizontal: gridLRMargin,
            vertical: gridTBMargin,
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      sortAscending: sort,
                      sortColumnIndex: index,
                      columns: [
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
                      rows: [
                        DataRow(
                          cells: [
                            ...columnDesc.map(
                              (c) => gridFilter(
                                  columnWidth: c["width"],
                                  columnIndex: c["position"],
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
                        ...filteredTasks.map(
                          (task) => DataRow(
                            cells: [
                              DataCell(
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 160),
                                  child: Text(
                                    task.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 520),
                                  child: Text(
                                    task.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Tooltip(
                                    message: "${task.progress}%",
                                    preferBelow: false,
                                    verticalOffset: -13,
                                    child: LinearPercentIndicator(
                                      percent: task.progress / 100,
                                      progressColor: task.progress >= 50
                                          ? Colors.green[400]
                                          : Colors.red[400],
                                      lineHeight: 15,
                                      width: 100,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                task.assigneeUserId > 0
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
                                            backgroundImage: NetworkImage(
                                              users
                                                  .firstWhere((u) =>
                                                      int.parse(u.id) ==
                                                      task.assigneeUserId)
                                                  .avatar,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const Center(),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      List<User> filteredAvatars = [...users];

                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
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
                                                    controller:
                                                        _textController[7],
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText:
                                                          "Search Assignee ...",
                                                      hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                    onChanged: (text) {
                                                      var query =
                                                          text.toLowerCase();
                                                      List<User> temp = [
                                                        ...users
                                                      ];

                                                      if (query.isNotEmpty) {
                                                        temp = temp
                                                            .where((u) => u.name
                                                                .toLowerCase()
                                                                .startsWith(
                                                                    query))
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
                                                  child: filteredAvatars
                                                          .isNotEmpty
                                                      ? GridView.builder(
                                                          gridDelegate:
                                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 3,
                                                          ),
                                                          itemCount:
                                                              filteredAvatars
                                                                  .length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return Center(
                                                              child: InkWell(
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 20,
                                                                  backgroundImage:
                                                                      NetworkImage(
                                                                    filteredAvatars[
                                                                            index]
                                                                        .avatar,
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  int position =
                                                                      allTasks.indexWhere((t) =>
                                                                          t.id ==
                                                                          task.id);
                                                                  Task updated =
                                                                      allTasks[
                                                                              position]
                                                                          .copy();
                                                                  updated.assigneeUserId =
                                                                      int.parse(
                                                                          filteredAvatars[index]
                                                                              .id);
                                                                  updateCell(
                                                                      task.id,
                                                                      updated,
                                                                      position);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
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
                                },
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    task.formattedDate!,
                                    maxLines: 1,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  task.urgencyName,
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.more_vert,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
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
                                    },
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
              ),
              TextField(
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
                          message: "New Task Title Must Exceed 5 Characters !",
                          width: 400,
                          isSuccess: false,
                          duration: 3),
                    );
                  } else {
                    addCell(text);
                  }
                },
              ),
            ],
          ),
        ),
        if (loading) const Loading(),
      ],
    );
  }
}
