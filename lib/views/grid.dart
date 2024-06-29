import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    tasks = widget.tasks;
    users = widget.users;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DataTable(
        columns: const [
          DataColumn(
            label: Text(
              "Title",
            ),
          ),
          DataColumn(
            label: Text(
              "Description",
            ),
          ),
          DataColumn(
            label: Text(
              "Progress",
            ),
          ),
          DataColumn(
            label: Text(
              "Assignee",
            ),
          ),
          DataColumn(
            label: Text(
              "Period",
            ),
          ),
          DataColumn(
            label: Text(
              "Urgency",
            ),
          ),
          DataColumn(
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
                        "${DateFormat("dd.MM.yyyy").format(task.startDate)} - ${DateFormat("dd.MM.yyyy").format(task.endDate)}",
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
    );
  }
}
