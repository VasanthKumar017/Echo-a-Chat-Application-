import 'package:flutter/material.dart';

class SnackBarService {
  BuildContext? _buildContext;

  static SnackBarService instance = SnackBarService();

  SnackBarService();

  set buildContext(BuildContext context) {
    _buildContext = context;
  }

  void showSnackBarError(String message) {
    if (_buildContext != null) {
      ScaffoldMessenger.of(_buildContext!).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      print("Error: Build context is null.");
    }
  }

  void showSnackBarSuccess(String message) {
    if (_buildContext != null) {
      ScaffoldMessenger.of(_buildContext!).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print("Error: Build context is null.");
    }
  }
}
