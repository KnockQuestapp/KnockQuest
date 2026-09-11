import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final String id;
  final String email;
  final String name;

  AuthUser({required this.id, required this.email, required this.name});
}

class AuthStore {
  AuthStore._();
  static final AuthStore instance = AuthStore._();

  final ValueNotifier<AuthUser?> currentUser = ValueNotifier<AuthUser?>(null);

  static const String _kSessionKey = 'knockquest_session_user';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getString(_kSessionKey);
    if (session != null) {
      // Simple session restoration from a stored ID/email for MVP
      // In a real app, we would verify the JWT token here
      currentUser.value = AuthUser(
        id: 'session-123',
        email: session,
        name: 'Returning User',
      );
    }
  }

  Future<bool> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      final user = AuthUser(
        id: 'user-123',
        email: email,
        name: email.split('@')[0],
      );
      currentUser.value = user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSessionKey, email);
      return true;
    }
    return false;
  }

  Future<bool> signUp(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      final user = AuthUser(
        id: 'user-456',
        email: email,
        name: name,
      );
      currentUser.value = user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSessionKey, email);
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    currentUser.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionKey);
  }
}
