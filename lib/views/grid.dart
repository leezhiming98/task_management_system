import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/task.dart';

class Grid extends StatefulWidget {
  final List<Task> data;

  const Grid({super.key, required this.data});

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  late List<Task> tasks;

  @override
  void initState() {
    super.initState();
    tasks = widget.data;
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
                    ),
                  ),
                  DataCell(
                    Text(
                      task.description,
                    ),
                  ),
                  DataCell(
                    LinearPercentIndicator(
                      percent: task.progress,
                      progressColor: Colors.green,
                      lineHeight: 10,
                    ),
                  ),
                  DataCell(
                    Text(
                      task.assigneeUserId.toString(),
                    ),
                  ),
                  DataCell(
                    Text(
                      "${DateFormat("dd.MM.yyyy").format(task.startDate)} - ${DateFormat("dd.MM.yyyy").format(task.endDate)}",
                    ),
                  ),
                  DataCell(
                    Text(
                      task.urgencyName,
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
