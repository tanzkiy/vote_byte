import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'login_page.dart';
import 'vote_homepage.dart';
import 'admin_screen.dart';
import 'services/auth_service.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    try {
      databaseFactory = databaseFactoryFfiWeb;
    } catch (e) {
      print('Warning: Could not initialize web database factory: $e');
    }
  }

  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (e) {
    firebaseReady = false;
  }
  AuthService.setFirebaseReady(firebaseReady);

  // Initialize the database helper to set up fallback mode if needed
  await DatabaseHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Widget>? _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _checkLoginStatus();
  }

  Future<Widget> _checkLoginStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        final user = await AuthService.getCurrentUser();
        final role = user?['role'];
        return role == 'admin' ? const AdminScreen() : const VoteHomePage();
      } else {
        return const LoginPage();
      }
    } catch (e) {
      print('Error checking login status: $e');
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _homeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading screen while checking login status
          return MaterialApp(
            title: 'BYTE Voting System',
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          // Handle error, show login page
          print('Error in app initialization: ${snapshot.error}');
          return MaterialApp(
            title: 'BYTE Voting System',
            home: const LoginPage(),
          );
        } else {
          return MaterialApp(
            title: 'BYTE Voting System',
            theme: ThemeData(
              primaryColor: const Color(0xFF2196F3),
              scaffoldBackgroundColor: const Color(0xFFE3F2FD),
              fontFamily: GoogleFonts.poppins().fontFamily,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: Colors.blue.withValues(alpha: 0.5),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2196F3),
                    width: 2,
                  ),
                ),
              ),
            ),
            home: snapshot.data ?? const LoginPage(),
          );
        }
      },
    );
  }
}
