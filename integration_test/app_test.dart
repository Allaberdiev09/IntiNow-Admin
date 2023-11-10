import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intinow/main.dart' as app;

void main() {
  group('App Test', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets("full app test", (WidgetTester tester) async{
      app.main();
      await tester.pumpAndSettle();
      
      final emailFormField = find.byType(TextFormField).first;
      final passwordFormField = find.byType(TextFormField).last;
      final loginButton = find.byType(ElevatedButton).first;

      await tester.enterText(emailFormField, "intinowaddmin@gmaol.com");
      await tester.enterText(passwordFormField, "Parol123");
      await tester.pumpAndSettle();
      
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

    });
  });
}
