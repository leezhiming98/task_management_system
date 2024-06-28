class User {
  String id;
  DateTime createdAt;
  String name;
  String avatar;

  User(
      {required this.id,
      required this.createdAt,
      required this.name,
      required this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json["id"],
        createdAt: DateTime.parse(json["createdAt"]),
        name: json["name"],
        avatar: json["avatar"]);
  }
}
