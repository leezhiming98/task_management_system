import 'package:intl/intl.dart';

class Task {
  String id;
  DateTime createdAt;
  int assigneeUserId;
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;
  int defaultPosition;
  String urgencyName;
  int progress;
  String? formattedDate;

  Task(
      {required this.id,
      required this.createdAt,
      required this.assigneeUserId,
      required this.title,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.defaultPosition,
      required this.urgencyName,
      required this.progress,
      this.formattedDate});

  factory Task.fromJson(Map<String, dynamic> json) {
    DateTime dtStartDate = DateTime.parse(json["startDate"]);
    DateTime dtEndDate = DateTime.parse(json["endDate"]);

    return Task(
      id: json["id"],
      createdAt: DateTime.parse(json["createdAt"]),
      assigneeUserId: json["assigneeUserId"],
      title: json["title"],
      description: json["description"],
      startDate: dtStartDate,
      endDate: dtEndDate,
      defaultPosition: json["defaultPosition"],
      urgencyName: json["urgencyName"],
      progress: json["progress"],
      formattedDate:
          "${DateFormat("dd.MM.yyyy").format(dtStartDate)} - ${DateFormat("dd.MM.yyyy").format(dtEndDate)}",
    );
  }
}
