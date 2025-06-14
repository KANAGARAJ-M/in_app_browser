import 'dart:async';
import 'package:flutter/services.dart';
import 'platform_interface.dart';

class InAppBrowserController {
  final InAppBrowserPlatform _platform = InAppBrowserPlatform();
  final StreamController<String> _urlStreamController = StreamController<String>.broadcast();
  final StreamController<String> _titleStreamController = StreamController<String>.broadcast();
  final StreamController<double> _progressStreamController = StreamController<double>.broadcast();
  final StreamController<bool> _loadingStreamController = StreamController<bool>.broadcast();
  
  Stream<String> get onUrlChanged => _urlStreamController.stream;
  Stream<String> get onTitleChanged => _titleStreamController.stream;
  Stream<double> get onProgressChanged => _progressStreamController.stream;
  Stream<bool> get onLoadingStateChanged => _loadingStreamController.stream;
  
  InAppBrowserController() {
    _platform.setMethodCallHandler(_handleMethodCall);
  }
  
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onUrlChanged':
        final String url = call.arguments['url'];
        _urlStreamController.add(url);
        break;
      case 'onTitleChanged':
        final String title = call.arguments['title'];
        _titleStreamController.add(title);
        break;
      case 'onProgressChanged':
        final double progress = call.arguments['progress'];
        _progressStreamController.add(progress);
        break;
      case 'onLoadingStateChanged':
        final bool isLoading = call.arguments['isLoading'];
        _loadingStreamController.add(isLoading);
        break;
    }
    return null;
  }
  
  /// Navigate to the provided URL
  Future<void> loadUrl(String url) => _platform.loadUrl(url);
  
  /// Go back in the browser history
  Future<void> goBack() => _platform.goBack();
  
  /// Go forward in the browser history
  Future<void> goForward() => _platform.goForward();
  
  /// Reload the current page
  Future<void> reload() => _platform.reload();
  
  /// Check if can go back
  Future<bool> canGoBack() => _platform.canGoBack();
  
  /// Check if can go forward
  Future<bool> canGoForward() => _platform.canGoForward();
  
  /// Get current URL
  Future<String> getCurrentUrl() => _platform.getCurrentUrl();
  
  /// Get page title
  Future<String> getTitle() => _platform.getTitle();
  
  /// Execute JavaScript
  Future<void> evaluateJavascript(String javascript) => 
      _platform.evaluateJavascript(javascript);
  
  /// Close and dispose resources
  void dispose() {
    _urlStreamController.close();
    _titleStreamController.close();
    _progressStreamController.close();
    _loadingStreamController.close();
  }
}