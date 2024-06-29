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
  late List<Task> tasks;
  late List<User> users;
  bool sort = false;
  int index = 0;

  void onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      index = columnIndex;
      sort = ascending;
    });

    switch (columnIndex) {
      case 0:
        ascending
            ? tasks.sort((a, b) => a.title.compareTo(b.title))
            : tasks.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 1:
        ascending
            ? tasks.sort((a, b) => a.description.compareTo(b.description))
            : tasks.sort((a, b) => b.description.compareTo(a.description));
        break;
      case 2:
        ascending
            ? tasks.sort((a, b) => a.progress.compareTo(b.progress))
            : tasks.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 3:
        ascending
            ? tasks.sort((a, b) => a.assigneeUserId.compareTo(b.assigneeUserId))
            : tasks
                .sort((a, b) => b.assigneeUserId.compareTo(a.assigneeUserId));
        break;
      case 4:
        ascending
            ? tasks.sort((a, b) => a.formattedDate!.compareTo(b.formattedDate!))
            : tasks
                .sort((a, b) => b.formattedDate!.compareTo(a.formattedDate!));
        break;
      case 5:
        ascending
            ? tasks.sort((a, b) => a.urgencyName.compareTo(b.urgencyName))
            : tasks.sort((a, b) => b.urgencyName.compareTo(a.urgencyName));
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    tasks = widget.tasks;
    users = widget.users;
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
          rows: tasks
              .map(
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
              )
              .toList(),
        ),
      ),
    );
  }
}
