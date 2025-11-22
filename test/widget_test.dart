// This is a basic Flutter widget test for VoteBit app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:votebit/login_page.dart';

void main() {
  testWidgets('Login page renders correctly', (WidgetTester tester) async {
    // Build the login page directly to avoid initialization issues
    await tester.pumpWidget(const MaterialApp(
      home: LoginPage(),
    ));
    
    // Wait for the widget to settle
    await tester.pump();

    // Verify that the login page elements are present
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets); // Should find email/password fields
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
