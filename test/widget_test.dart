// Hospital Appointment Management System - Widget Tests
// Following WINDSURF AI Rules

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:Go Hospital/main.dart';
import 'package:Go Hospital/core/providers/theme_provider.dart';
import 'package:Go Hospital/core/providers/auth_provider.dart';

void main() {
  testWidgets('Go Hospital app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const Go HospitalApp(),
      ),
    );

    // Verify that the splash screen shows the app name
    expect(find.text('Go Hospital'), findsOneWidget);
    expect(find.text('Hospital Appointment & Service System'), findsOneWidget);
    
    // Verify loading indicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Verify hospital icon is present
    expect(find.byIcon(Icons.local_hospital), findsOneWidget);
  });
}
