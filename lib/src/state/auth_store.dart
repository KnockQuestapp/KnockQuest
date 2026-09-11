import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthUser {
  final String id;
  final String email;
  final String name;

  AuthUser({required this.id, required this.email, required this.name});

  factory AuthUser.fromSupabase(User user) {
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['full_name'] ?? user.email ?? 'User',
    );
  }
}

class AuthStore {
  AuthStore._();
  static final AuthStore instance = AuthStore._();

  final ValueNotifier<AuthUser?> currentUser = ValueNotifier<AuthUser?>(null);

  Future<void> init() async {
    final supabaseUser = SupabaseService.instance.currentUser;
    if (supabaseUser != null) {
      currentUser.value = AuthUser.fromSupabase(supabaseUser);
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await SupabaseService.instance.signIn(email, password);
      if (response.user != null) {
        currentUser.value = AuthUser.fromSupabase(response.user!);
        return true;
      }
    } catch (e) {
      print('Sign in error: $e');
    }
    return false;
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      final response = await SupabaseService.instance.signUp(email, password, name: name);
      if (response.user != null) {
        currentUser.value = AuthUser.fromSupabase(response.user!);
        return true;
      }
    } catch (e) {
      print('Sign up error: $e');
    }
    return false;
  }

  Future<void> signOut() async {
    await SupabaseService.instance.signOut();
    currentUser.value = null;
  }
}
