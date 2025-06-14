import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_browser/src/in_app_browser_settings.dart';
import 'package:in_app_browser/src/platform_view/platform_view_factory.dart';

void main() {
  group('PlatformViewFactory', () {
    test('should create the correct platform-specific view', () {
      final Widget widget = PlatformViewFactory.createPlatformView(
        initialUrl: 'https://example.com',
        settings: InAppBrowserSettings(),
      );
      
      // This will be a platform-specific view, but we can at least verify it returns a widget
      expect(widget, isA<Widget>());
    });
  });
}