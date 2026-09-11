import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  void showSuccess(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }

  void showError(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.red,
    );
  }

  void showInfo(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.blue,
    );
  }

  void _showSnackBar(String message, {required Color backgroundColor}) {
    if (_context == null) return;

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
