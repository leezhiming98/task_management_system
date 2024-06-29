import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/task.dart';
import '../models/user.dart';
import 'grid.dart';
import 'error.dart';

class Home extends StatefulWidget {
  final String title;

  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Task>> futureTasks;
  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureTasks = getTasks();
    futureUsers = getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([futureTasks, futureUsers]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            List<Task> tasks = snapshot.data![0];
            List<User> users = snapshot.data![1];
            return Grid(
              tasks: tasks,
              users: users,
            );
          } else if (snapshot.hasError) {
            return Error(
              message: "${snapshot.error}",
            );
          }

          return const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          );
        },
      ),
    );
  }
}
