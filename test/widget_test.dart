// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intinow/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    final emailFormField = find.byType(TextFormField).first;
    final passwordFormField = find.byType(TextFormField).last;
    final loginButton = find.byType(ElevatedButton).first;

    await tester.enterText(emailFormField, "intinowaddmin@gmaol.com");
    await tester.enterText(passwordFormField, "Parol123");
    await tester.pumpAndSettle();

    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  });
}
