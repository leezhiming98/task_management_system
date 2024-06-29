import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/task.dart';
import '../models/user.dart';

class Grid extends StatefulWidget {
  final List<Task> tasks;
  final List<User> users;

  const Grid({super.key, required this.tasks, required this.users});

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  late List<Task> initTasks;
  late List<User> users;
  bool sort = false;
  int index = 0;
  late List<Task> filteredTasks;
  final List<TextEditingController> _controller =
      List.generate(6, (i) => TextEditingController());

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

  void onFilterColumn(int columnIndex, String text) {
    text = text.toLowerCase();

    switch (columnIndex) {
      case 0:
        setState(() {
          filteredTasks = text.isNotEmpty
              ? initTasks
                  .where((t) => t.title.toLowerCase().startsWith(text))
                  .toList()
              : initTasks;
        });
        break;
      case 1:
        setState(() {
          filteredTasks = text.isNotEmpty
              ? initTasks
                  .where((t) => t.description.toLowerCase().startsWith(text))
                  .toList()
              : initTasks;
        });
        break;
      case 3:
        setState(() {
          var uIds = users
              .where((u) => u.name.toLowerCase().startsWith(text))
              .map((u) => int.parse(u.id))
              .toList();
          filteredTasks = text.isNotEmpty
              ? initTasks.where((t) => uIds.contains(t.assigneeUserId)).toList()
              : initTasks;
        });
        break;
      case 4:
        setState(() {
          filteredTasks = text.isNotEmpty
              ? initTasks
                  .where((t) => t.formattedDate!.startsWith(text))
                  .toList()
              : initTasks;
        });
        break;
      case 5:
        setState(() {
          filteredTasks = text.isNotEmpty
              ? initTasks
                  .where((t) => t.urgencyName.toLowerCase().startsWith(text))
                  .toList()
              : initTasks;
        });
        break;
      default:
        setState(() {
          filteredTasks = initTasks;
        });
        for (var c in _controller) {
          c.clear();
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    initTasks = filteredTasks = widget.tasks;
    users = widget.users;
  }

  @override
  void dispose() {
    for (var c in _controller) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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
                  TextField(
                    controller: _controller[0],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Filter Title ...",
                      hintStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    onChanged: (text) {
                      onFilterColumn(0, text);
                    },
                  ),
                ),
                DataCell(
                  TextField(
                    controller: _controller[1],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Filter Description ...",
                      hintStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    onChanged: (text) {
                      onFilterColumn(1, text);
                    },
                  ),
                ),
                const DataCell(
                  Center(),
                ),
                DataCell(
                  TextField(
                    controller: _controller[3],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Filter Assignee ...",
                      hintStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    onChanged: (text) {
                      onFilterColumn(3, text);
                    },
                  ),
                ),
                DataCell(
                  TextField(
                    controller: _controller[4],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Filter Period ...",
                      hintStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    onChanged: (text) {
                      onFilterColumn(4, text);
                    },
                  ),
                ),
                DataCell(
                  TextField(
                    controller: _controller[5],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Filter Urgency ...",
                      hintStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    onChanged: (text) {
                      onFilterColumn(5, text);
                    },
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(
                      Icons.clear,
                    ),
                    onPressed: () {
                      onFilterColumn(-1, "");
                    },
                  ),
                ),
              ],
            ),
            ...filteredTasks.map(
              (task) => DataRow(
                cells: [
                  DataCell(
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
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
                            .firstWhere(
                                (u) => int.parse(u.id) == task.assigneeUserId)
                            .name,
                        preferBelow: false,
                        verticalOffset: -13,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(
                            users
                                .firstWhere((u) =>
                                    int.parse(u.id) == task.assigneeUserId)
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
    );
  }
}
