import 'package:flutter/material.dart';

class Error extends StatelessWidget {
  final String message;

  const Error({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red[400],
          border: Border.all(
            color: Colors.white70,
            width: 8,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
