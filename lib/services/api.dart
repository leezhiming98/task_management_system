import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/task.dart';
import '../models/user.dart';

// TASK APIs
String taskUrl = "https://667d6a99297972455f650cbb.mockapi.io/api/tms/task";

Future<List<Task>> getTasks() async {
  final response = await http.get(Uri.parse(taskUrl));

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    return data.map((d) => Task.fromJson(d)).toList();
  } else {
    throw Exception("Failed To Fetch Tasks!");
  }
}

Future<Task> addTask(Task task) async {
  final response = await http.post(
    Uri.parse(taskUrl),
    headers: {"Content-Type": "application/json; charset=UTF-8"},
    body: jsonEncode(task.toJson()),
  );

  if (response.statusCode == 201) {
    var data = jsonDecode(response.body);
    return Task.fromJson(data);
  } else {
    throw Exception("Failed To Add or Duplicate Task!");
  }
}

Future<bool> deleteTask(String id) async {
  final response = await http.delete(Uri.parse("$taskUrl/$id"),
      headers: {"Content-Type": "application/json; charset=UTF-8"});

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception("Failed To Delete Task!");
  }
}

// USER APIs
String userUrl = "https://667d6a99297972455f650cbb.mockapi.io/api/tms/user";

Future<List<User>> getUsers() async {
  final response = await http.get(Uri.parse(userUrl));

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    return data.map((d) => User.fromJson(d)).toList();
  } else {
    throw Exception("Failed To Fetch Users!");
  }
}
