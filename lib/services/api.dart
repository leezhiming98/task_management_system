import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/task.dart';
import '../models/user.dart';

// Task APIs
String taskUrl = "https://667d6a99297972455f650cbb.mockapi.io/api/tms/task";

Future<List<Task>> getTasks() async {
  final response = await http.get(Uri.parse(taskUrl));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((d) => Task.fromJson(d)).toList();
  } else {
    throw Exception("Failed To Fetch Tasks!");
  }
}

// User APIs
String userUrl = "https://667d6a99297972455f650cbb.mockapi.io/api/tms/user";

Future<List<User>> getUsers() async {
  final response = await http.get(Uri.parse(userUrl));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((d) => User.fromJson(d)).toList();
  } else {
    throw Exception("Failed To Fetch Users!");
  }
}
