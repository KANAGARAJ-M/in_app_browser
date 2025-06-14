import 'package:flutter/services.dart';

class InAppBrowserPlatform {
  static const MethodChannel _channel = MethodChannel('com.nocorps.in_app_browser');
  
  Future<void> loadUrl(String url) async {
    await _channel.invokeMethod('loadUrl', {'url': url});
  }
  
  Future<void> goBack() async {
    await _channel.invokeMethod('goBack');
  }
  
  Future<void> goForward() async {
    await _channel.invokeMethod('goForward');
  }
  
  Future<void> reload() async {
    await _channel.invokeMethod('reload');
  }
  
  Future<bool> canGoBack() async {
    return await _channel.invokeMethod('canGoBack') ?? false;
  }
  
  Future<bool> canGoForward() async {
    return await _channel.invokeMethod('canGoForward') ?? false;
  }
  
  Future<String> getCurrentUrl() async {
    return await _channel.invokeMethod('getCurrentUrl') ?? '';
  }
  
  Future<String> getTitle() async {
    return await _channel.invokeMethod('getTitle') ?? '';
  }
  
  Future<void> evaluateJavascript(String javascript) async {
    await _channel.invokeMethod('evaluateJavascript', {'javascript': javascript});
  }
  
  Future<void> setMethodCallHandler(Future<dynamic> Function(MethodCall call) handler) async {
    _channel.setMethodCallHandler(handler);
  }
}