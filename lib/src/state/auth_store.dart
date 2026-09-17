import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';

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
    final userData = LocalStorageService.instance.loadUser();
    if (userData != null) {
      currentUser.value = AuthUser(
        id: userData['id'] as String,
        email: userData['email'] as String,
        name: userData['name'] as String,
      );
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final userData = LocalStorageService.instance.loadUser();
      if (userData != null && 
          userData['email'] == email && 
          userData['password'] == password) {
        
        currentUser.value = AuthUser(
          id: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String,
        );
        return true;
      }
      
      // For MVP ease: allow any login if password is 'password'
      if (password == 'password') {
        final user = AuthUser(id: 'local_1', email: email, name: 'Local User');
        currentUser.value = user;
        await LocalStorageService.instance.saveUser({
          'id': user.id,
          'email': user.email,
          'name': user.name,
          'password': password,
        });
        return true;
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
    }
    return false;
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      final user = AuthUser(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
      );
      
      await LocalStorageService.instance.saveUser({
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'password': password,
      });
      
      currentUser.value = user;
      return true;
    } catch (e) {
      debugPrint('Sign up error: $e');
    }
    return false;
  }

  Future<void> signOut() async {
    await LocalStorageService.instance.clearUser();
    currentUser.value = null;
  }
}
