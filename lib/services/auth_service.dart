import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _usersKey = 'users';

  // Login method - now uses local storage
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson != null) {
      final users = json.decode(usersJson) as Map<String, dynamic>;

      // Find user by email
      final userEntry = users.entries.firstWhere(
        (entry) => entry.value['email'] == email,
        orElse: () => MapEntry('', null),
      );

      if (userEntry.value != null) {
        final userData = userEntry.value as Map<String, dynamic>;
        if (userData['password'] == password) {
          await prefs.setString(_userKey, userEntry.key);
          await prefs.setBool(_isLoggedInKey, true);

          return {
            'success': true,
            'user': {
              'uid': userEntry.key,
              'name': userData['name'],
              'email': userData['email'],
              'role': userData['role'],
            },
          };
        }
      }
    }

    return {'success': false, 'message': 'Invalid email or password'};
  }

  // Signup method - now uses local storage
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    Map<String, dynamic> users = {};

    if (usersJson != null) {
      users = json.decode(usersJson) as Map<String, dynamic>;
    }

    // Check if email already exists
    final existingUser = users.values.any((user) => user['email'] == email);
    if (existingUser) {
      return {'success': false, 'message': 'Email already exists'};
    }

    // Create new user
    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    users[uid] = {
      'name': fullName,
      'email': email,
      'password': password,
      'role': role,
      'hasVoted': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_usersKey, json.encode(users));
    await prefs.setString(_userKey, uid);
    await prefs.setBool(_isLoggedInKey, true);

    return {
      'success': true,
      'user': {'uid': uid, 'name': fullName, 'email': email, 'role': role},
    };
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user
  static Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_userKey);

    if (uid != null) {
      final usersJson = prefs.getString(_usersKey);
      if (usersJson != null) {
        final users = json.decode(usersJson) as Map<String, dynamic>;
        final userData = users[uid] as Map<String, dynamic>?;
        if (userData != null) {
          return {
            'uid': uid,
            'name': userData['name'],
            'email': userData['email'],
            'role': userData['role'],
          };
        }
      }
    }

    return null;
  }

  // Logout method
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Get current user UID
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  // Get all users (for admin purposes)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson != null) {
      final users = json.decode(usersJson) as Map<String, dynamic>;
      return users.values.map((user) => user as Map<String, dynamic>).toList();
    }

    return [];
  }

  // Update user data
  static Future<void> updateUserData(
    String uid,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson != null) {
      final users = json.decode(usersJson) as Map<String, dynamic>;
      if (users.containsKey(uid)) {
        users[uid].addAll(data);
        await prefs.setString(_usersKey, json.encode(users));
      }
    }
  }
}
