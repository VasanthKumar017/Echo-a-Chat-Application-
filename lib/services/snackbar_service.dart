import 'package:flutter/material.dart';

class SnackBarService {
  BuildContext? _buildContext;

  static SnackBarService instance = SnackBarService();

  SnackBarService() {}

  set buildContext(BuildContext _context) {
    _buildContext = _context;
  }

  void showSnackBarError(String _message) {
    if (_buildContext != null) {
      ScaffoldMessenger.of(_buildContext!).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            _message,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      print("Error: Build context is null.");
    }
  }

  void showSnackBarSuccess(String _message) {
    if (_buildContext != null) {
      ScaffoldMessenger.of(_buildContext!).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            _message,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print("Error: Build context is null.");
    }
  }
}
