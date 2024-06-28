import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/task.dart';
import './error.dart';

class Home extends StatefulWidget {
  final String title;

  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Task>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = getTasks();
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
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Task> tasks = snapshot.data!;
            return Center(
              child: Text(
                tasks[0].title,
              ),
            );
          } else if (snapshot.hasError) {
            return Error(
              message: "${snapshot.error}",
            );
          }

          return const CircularProgressIndicator(
            color: Colors.lightBlueAccent,
          );
        },
      ),
    );
  }
}
