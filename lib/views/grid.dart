import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/task.dart';
import '../models/user.dart';
import 'loading.dart';

class Grid extends StatefulWidget {
  final List<Task> tasks;
  final List<User> users;

  const Grid({super.key, required this.tasks, required this.users});

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  late List<Task> allTasks;
  late List<Task> initTasks; // for filtering use
  late List<User> users;
  int currentPage = 0;
  int pageSize = 15;
  bool loading = false;
  bool sort = false;
  int index = 0;
  late List<Task> filteredTasks;
  Map<String, String> filterQuery = {
    "title": "",
    "description": "",
    "assignee": "",
    "formattedDate": "",
    "urgencyName": ""
  };

  final ScrollController _scrollController = ScrollController();
  final List<TextEditingController> _textController =
      List.generate(6, (i) => TextEditingController());

  final infoToast = SnackBar(
    content: const Center(
      child: Text(
        "All tasks have been successfully loaded!",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    width: 400,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.green[400],
    showCloseIcon: true,
    duration: const Duration(seconds: 1),
  );

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
      for (var c in _textController) {
        c.clear();
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
      ScaffoldMessenger.of(context).showSnackBar(infoToast);
    }
  }

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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              child: DataTable(
                sortAscending: sort,
                sortColumnIndex: index,
                columns: [
                  DataColumn(
                    label: const Text(
                      "Title",
                    ),
                    onSort: (columnIndex, ascending) {
                      onSortColumn(columnIndex, ascending);
                    },
                  ),
                  DataColumn(
                    label: const Text(
                      "Description",
                    ),
                    onSort: (columnIndex, ascending) {
                      onSortColumn(columnIndex, ascending);
                    },
                  ),
                  DataColumn(
                    label: const Text(
                      "Progress",
                    ),
                    onSort: (columnIndex, ascending) {
                      onSortColumn(columnIndex, ascending);
                    },
                  ),
                  DataColumn(
                    label: const Text(
                      "Assignee",
                    ),
                    onSort: (columnIndex, ascending) {
                      onSortColumn(columnIndex, ascending);
                    },
                  ),
                  DataColumn(
                    label: const Text(
                      "Period",
                    ),
                    onSort: (columnIndex, ascending) {
                      onSortColumn(columnIndex, ascending);
                    },
                  ),
                  DataColumn(
                    label: const Text(
                      "Urgency",
                    ),
                    onSort: (columnIndex, ascending) {
                      onSortColumn(columnIndex, ascending);
                    },
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
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: TextField(
                            controller: _textController[0],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Filter Title ...",
                              hintStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onChanged: (text) {
                              setState(() {
                                filterQuery["title"] = text;
                              });
                              onFilterColumn(query: filterQuery);
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 520,
                          child: TextField(
                            controller: _textController[1],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Filter Description ...",
                              hintStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onChanged: (text) {
                              setState(() {
                                filterQuery["description"] = text;
                              });
                              onFilterColumn(query: filterQuery);
                            },
                          ),
                        ),
                      ),
                      const DataCell(
                        SizedBox(
                          width: 100,
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _textController[3],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Filter Assignee ...",
                              hintStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onChanged: (text) {
                              setState(() {
                                filterQuery["assignee"] = text;
                              });
                              onFilterColumn(query: filterQuery);
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: TextField(
                            controller: _textController[4],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Filter Period ...",
                              hintStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onChanged: (text) {
                              setState(() {
                                filterQuery["formattedDate"] = text;
                              });
                              onFilterColumn(query: filterQuery);
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _textController[5],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Filter Urgency ...",
                              hintStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            onChanged: (text) {
                              setState(() {
                                filterQuery["urgencyName"] = text;
                              });
                              onFilterColumn(query: filterQuery);
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 48,
                          child: IconButton(
                            icon: const Icon(
                              Icons.clear,
                            ),
                            onPressed: () {
                              setState(() {
                                filterQuery.forEach(
                                    (key, value) => filterQuery[key] = "");
                              });
                              onFilterColumn(query: filterQuery, clear: true);
                            },
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
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
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
                          Center(
                            child: Tooltip(
                              message: users
                                  .firstWhere((u) =>
                                      int.parse(u.id) == task.assigneeUserId)
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
                          ),
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
                        const DataCell(
                          Text(
                            "",
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
        if (loading) const Loading(),
      ],
    );
  }
}
