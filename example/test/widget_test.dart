// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('In-App Browser example app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Verify the URL input field exists
    expect(find.byType(TextField), findsOneWidget);
    
    // Verify the Open URL button exists
    expect(find.text('Open URL'), findsOneWidget);
    
    // Verify the embedded browser demo button exists
    expect(find.text('Try Embedded Browser'), findsOneWidget);
    
    // Test tapping the button (this would normally open a browser, but in tests it won't actually render)
    await tester.tap(find.text('Open URL'));
    await tester.pumpAndSettle();
  });
}
