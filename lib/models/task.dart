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
      required this.progress});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
        id: json["id"],
        createdAt: DateTime.parse(json["createdAt"]),
        assigneeUserId: json["assigneeUserId"],
        title: json["title"],
        description: json["description"],
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        defaultPosition: json["defaultPosition"],
        urgencyName: json["urgencyName"],
        progress: json["progress"]);
  }
}
