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
  bool isEditing;

  Task({
    required this.id,
    required this.createdAt,
    required this.assigneeUserId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.defaultPosition,
    required this.urgencyName,
    required this.progress,
    this.formattedDate,
    required this.isEditing,
  });

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
      isEditing: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt.toIso8601String(),
      "assigneeUserId": assigneeUserId,
      "title": title,
      "description": description,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "defaultPosition": defaultPosition,
      "urgencyName": urgencyName,
      "progress": progress,
    };
  }

  Task copy() {
    return Task(
      id: "",
      createdAt: DateTime.now(),
      assigneeUserId: assigneeUserId,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      defaultPosition: defaultPosition,
      urgencyName: urgencyName,
      progress: progress,
      formattedDate: formattedDate,
      isEditing: false,
    );
  }
}
