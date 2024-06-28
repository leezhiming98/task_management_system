import 'package:flutter/material.dart';
import './views/home.dart';

void main() {
  runApp(const MyApp(header: "Task Management System"));
}

class MyApp extends StatelessWidget {
  final String header;

  const MyApp({super.key, required this.header});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: header,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: Home(
        title: header,
      ),
    );
  }
}
