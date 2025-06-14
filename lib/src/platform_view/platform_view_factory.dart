import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../in_app_browser_settings.dart';
import 'android_webview.dart';
import 'ios_webview.dart';
import 'desktop_webview.dart';
import 'web_webview.dart';

typedef WebViewCreatedCallback = void Function(dynamic controller);

class PlatformViewFactory {
  static Widget createPlatformView({
    required String initialUrl,
    required InAppBrowserSettings settings,
    WebViewCreatedCallback? onWebViewCreated,
  }) {
    if (kIsWeb) {
      return WebWebView(
        initialUrl: initialUrl,
        settings: settings,
        onWebViewCreated: onWebViewCreated,
      );
    }
    
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
}