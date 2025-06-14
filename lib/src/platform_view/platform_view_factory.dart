import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../in_app_browser_settings.dart';
import 'android_webview.dart';
import 'ios_webview.dart';
import 'desktop_webview.dart';
import 'web_webview.dart';
import 'mock_webview.dart';

typedef WebViewCreatedCallback = void Function(dynamic controller);

class PlatformViewFactory {
  // Add a flag to determine if we're in test mode
  static bool testMode = false;

  static Widget createPlatformView({
    required String initialUrl,
    required InAppBrowserSettings settings,
    WebViewCreatedCallback? onWebViewCreated,
  }) {
    // In test mode, always return the mock
    if (testMode) {
      return MockWebView(
        initialUrl: initialUrl,
        settings: settings,
        onWebViewCreated: onWebViewCreated,
      );
    }

    try {
      if (kIsWeb) {
        return WebWebView(
          initialUrl: initialUrl,
          settings: settings,
          onWebViewCreated: onWebViewCreated,
        );
      }
      
      // Use Platform class for platform detection
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          return AndroidWebView(
            initialUrl: initialUrl,
            settings: settings,
            onWebViewCreated: onWebViewCreated,
          );
        }
        
        if (Platform.isIOS) {
          return IOSWebView(
            initialUrl: initialUrl,
            settings: settings,
            onWebViewCreated: onWebViewCreated,
          );
        }
        
        // Desktop platforms
        return DesktopWebView(
          initialUrl: initialUrl,
          settings: settings,
          onWebViewCreated: onWebViewCreated,
        );
      }
    } catch (e) {
      // Fallback to mock in case of platform detection issues
      return MockWebView(
        initialUrl: initialUrl,
        settings: settings,
        onWebViewCreated: onWebViewCreated,
      );
    }

    // Default fallback
    return MockWebView(
      initialUrl: initialUrl,
      settings: settings,
      onWebViewCreated: onWebViewCreated,
    );
  }
}