import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static bool _firebaseReady = false;

  static void setFirebaseReady(bool ready) {
    _firebaseReady = ready;
  }

  static bool isFirebaseReady() {
    return _firebaseReady;
  }

  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    if (_firebaseReady) {
      try {
        final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Add null check for cred.user to prevent 'eventId' null access error
        if (cred.user == null) {
          return {'success': false, 'message': 'Authentication failed - user not returned'};
        }
        final uid = cred.user!.uid;
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (!doc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'id': uid,
            'name': cred.user!.displayName ?? '',
            'email': email,
            'role': 'user',
            'hasVoted': 0,
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, uid);
        await prefs.setBool(_isLoggedInKey, true);
        final data = (await FirebaseFirestore.instance.collection('users').doc(uid).get()).data() ?? {};
        return {
          'success': true,
          'user': {
            'uid': uid,
            'name': data['name'] ?? '',
            'email': data['email'] ?? email,
            'role': data['role'] ?? 'user',
          },
        };
      } catch (e) {
        String message = 'Invalid email or password';
        try {
          if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'user-not-found':
                message = 'User not found';
                break;
              case 'wrong-password':
                message = 'Incorrect password';
                break;
              case 'invalid-email':
                message = 'Invalid email';
                break;
              case 'user-disabled':
                message = 'User account disabled';
                break;
              default:
                message = 'Authentication failed';
            }
          }
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } else {
      final db = DatabaseHelper();
      await db.database;
      final user = await db.getUserByEmail(email);
      if (user != null && user['password'] == password) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, user['id']);
        await prefs.setBool(_isLoggedInKey, true);
        return {
          'success': true,
          'user': {
            'uid': user['id'],
            'name': user['name'],
            'email': user['email'],
            'role': user['role'],
          },
        };
      }
      return {'success': false, 'message': 'Invalid email or password'};
    }
  }

  // Signup
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    if (_firebaseReady) {
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = cred.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'id': uid,
          'name': fullName,
          'email': email,
          'role': role,
          'hasVoted': 0,
          'createdAt': DateTime.now().toIso8601String(),
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, uid);
        await prefs.setBool(_isLoggedInKey, true);
        return {
          'success': true,
          'user': {'uid': uid, 'name': fullName, 'email': email, 'role': role},
        };
      } catch (e) {
        String message = 'Signup failed';
        try {
          if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'email-already-in-use':
                message = 'Email already in use';
                break;
              case 'invalid-email':
                message = 'Invalid email';
                break;
              case 'weak-password':
                message = 'Weak password';
                break;
              default:
                message = 'Signup failed';
            }
          }
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } else {
      final db = DatabaseHelper();
      await db.database;
      final existingUser = await db.getUserByEmail(email);
      if (existingUser != null) {
        return {'success': false, 'message': 'Email already exists'};
      }
      final uid = DateTime.now().millisecondsSinceEpoch.toString();
      final user = {
        'id': uid,
        'name': fullName,
        'email': email,
        'password': password,
        'role': role,
        'hasVoted': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await db.insertUser(user);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, uid);
      await prefs.setBool(_isLoggedInKey, true);
      return {
        'success': true,
        'user': {'uid': uid, 'name': fullName, 'email': email, 'role': role},
      };
    }
  }

  // Is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_firebaseReady) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null) {
          return {
            'uid': user.uid,
            'name': data['name'] ?? user.displayName ?? '',
            'email': data['email'] ?? user.email ?? '',
            'role': data['role'] ?? 'user',
          };
        }
      }
      return null;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString(_userKey);
      if (uid != null) {
        final db = DatabaseHelper();
        await db.database;
        final user = await db.getUserById(uid);
        if (user != null) {
          return {
            'uid': uid,
            'name': user['name'],
            'email': user['email'],
            'role': user['role'],
          };
        }
      }
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
    if (_firebaseReady) {
      await FirebaseAuth.instance.signOut();
    }
  }

  // Get current user ID
  static Future<String?> getCurrentUserId() async {
    if (_firebaseReady) {
      return FirebaseAuth.instance.currentUser?.uid;
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userKey);
    }
  }

  // Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (_firebaseReady) {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      return snapshot.docs.map((d) => d.data()).toList();
    } else {
      final db = DatabaseHelper();
      await db.database;
      return await db.getUsers();
    }
  }

  // Update user
  static Future<void> updateUserData(
    String uid,
    Map<String, dynamic> data,
  ) async {
    if (_firebaseReady) {
      final updateData = <String, Object>{};
      data.forEach((k, v) => updateData[k] = v as Object);
      await FirebaseFirestore.instance.collection('users').doc(uid).update(updateData);
    } else {
      final db = DatabaseHelper();
      await db.database;
      final updateData = <String, Object>{};
      data.forEach((k, v) => updateData[k] = v as Object);
      await db.updateUser(uid, updateData);
    }
  }

  // Update display name
  static Future<void> updateDisplayName(String newName) async {
    if (_firebaseReady) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': newName,
        });
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString(_userKey);
      if (uid != null) {
        final db = DatabaseHelper();
        await db.database;
        await db.updateUser(uid, {'name': newName});
      }
    }
  }

  // Update email
  static Future<void> updateEmail(String newEmail, {String? currentPassword}) async {
    if (_firebaseReady) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Re-authenticate user if password is provided (required for sensitive operations)
          if (currentPassword != null && currentPassword.isNotEmpty) {
            final credential = EmailAuthProvider.credential(
              email: user.email!,
              password: currentPassword,
            );
            await user.reauthenticateWithCredential(credential).timeout(const Duration(seconds: 10));
          }
          
          // For prototype: Update only in Firestore, not in Firebase Auth
          // This avoids the email verification requirement
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'email': newEmail,
          }).timeout(const Duration(seconds: 10));
        }
      } catch (e) {
        // Handle Firebase authentication errors including 'eventId' null access
        print('Firebase email update error: $e');
        
        // Check if it's a re-authentication required error
        if (e.toString().contains('requires-recent-login') || e.toString().contains('requires recent authentication')) {
          throw Exception('Please provide your current password to update your email address');
        }
        
        // Handle timeout errors gracefully
        if (e is TimeoutException) {
          throw Exception('Email update timed out. Please check your internet connection and try again.');
        }
        
        throw Exception('Failed to update email: ${e.toString()}');
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString(_userKey);
      if (uid != null) {
        final db = DatabaseHelper();
        await db.database;
        await db.updateUser(uid, {'email': newEmail});
      }
    }
  }

  // Update password
  static Future<void> updatePassword(String currentPassword, String newPassword) async {
    if (_firebaseReady) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Re-authenticate user first
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString(_userKey);
      if (uid != null) {
        final db = DatabaseHelper();
        await db.database;
        final user = await db.getUserById(uid);
        if (user != null && user['password'] == currentPassword) {
          await db.updateUser(uid, {'password': newPassword});
        } else {
          throw Exception('Current password is incorrect');
        }
      }
    }
  }

  // Update profile image (store locally for both Firebase and local modes)
  static Future<void> updateProfileImage(Uint8List imageBytes) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _firebaseReady ? FirebaseAuth.instance.currentUser?.uid : prefs.getString(_userKey);
    
    if (uid != null) {
      // Convert image to Base64
      final bytes = imageBytes;
      final base64Image = base64Encode(bytes);

      if (_firebaseReady) {
        // For Firebase mode, store the Base64 string in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profileImage': base64Image,
        });
      } else {
        // For local mode, store in SQLite
        final db = DatabaseHelper();
        await db.database;
        await db.updateUser(uid, {'profileImage': base64Image});
      }
    }
  }

  static Future<String?> getProfileImage() async {
    final userData = await getCurrentUser();
    if (userData != null) {
      if (_firebaseReady) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(userData['uid']).get();
        return doc.data()?['profileImage'] as String?;
      } else {
        final db = DatabaseHelper();
        await db.database;
        final user = await db.getUserById(userData['uid']);
        return user?['profileImage'] as String?;
      }
    }
    return null;
  }
}
