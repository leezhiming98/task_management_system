import 'package:flutter/material.dart';

SnackBar toast(
    {required String message,
    required double width,
    required bool isSuccess,
    required int duration}) {
  return SnackBar(
    content: Center(
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    width: width,
    behavior: SnackBarBehavior.floating,
    backgroundColor: isSuccess ? Colors.green[400] : Colors.red[400],
    showCloseIcon: true,
    duration: Duration(seconds: duration),
  );
}
