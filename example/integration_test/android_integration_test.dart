import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Android WebView Tests', () {
    testWidgets('should load URL and show controls on Android', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enter a URL
      await tester.enterText(find.byType(TextField), 'https://flutter.dev');
      await tester.pumpAndSettle();

      // Open the browser
      await tester.tap(find.text('Open URL'));
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Allow time for WebView to load
      
      // Verify browser UI elements (some might not be visible in integration tests)
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      // Close the browser
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      
      // Verify we're back at the main screen
      expect(find.text('Open URL'), findsOneWidget);
    });
  });
}