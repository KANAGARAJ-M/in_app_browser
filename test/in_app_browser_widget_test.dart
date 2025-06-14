import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_browser/src/in_app_browser_widget.dart';
import 'package:mockito/mockito.dart';

// Create mock class for controller
class MockController extends Mock {
  Future<bool> canGoBack() async => false;
  Future<bool> canGoForward() async => false;
  Future<void> loadUrl(String url) async {}
}

void main() {
  group('InAppBrowser Widget', () {
    testWidgets('should render with correct initial properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppBrowser(
              initialUrl: 'https://example.com',
              title: 'Test Title',
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              showProgressBar: true,
              enableShare: true,
              enableRefresh: true,
              enableBackForward: true,
            ),
          ),
        ),
      );
      
      // Wait for the widget to build
      await tester.pumpAndSettle();
      
      // Find the title text
      expect(find.text('Test Title'), findsOneWidget);
      
      // Check for control buttons
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
    
    testWidgets('should hide controls when showControls is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppBrowser(
              initialUrl: 'https://example.com',
              showControls: false,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Navigation controls should not be visible
      expect(find.byIcon(Icons.arrow_back_ios), findsNothing);
      expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });
  });
}