class Task {
  int id;
  DateTime createdAt;
  int assigneeUserId;
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;
  int defaultPosition;
  String urgencyName;

  Task(
      {required this.id,
      required this.createdAt,
      required this.assigneeUserId,
      required this.title,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.defaultPosition,
      required this.urgencyName});
}
