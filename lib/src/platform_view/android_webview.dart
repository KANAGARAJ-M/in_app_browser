import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../in_app_browser_settings.dart';
import 'platform_view_factory.dart';

class AndroidWebView extends StatefulWidget {
  final String initialUrl;
  final InAppBrowserSettings settings;
  final WebViewCreatedCallback? onWebViewCreated;

  const AndroidWebView({
    super.key,
    required this.initialUrl,
    required this.settings,
    this.onWebViewCreated,
  });

  @override
  State<AndroidWebView> createState() => _AndroidWebViewState();
}

class _AndroidWebViewState extends State<AndroidWebView> {
  @override
  Widget build(BuildContext context) {
    const String viewType = 'com.nocorps.in_app_browser/webview';
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialUrl': widget.initialUrl,
      'settings': widget.settings.toMap(),
    };

    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onWebViewCreated != null) {
      final controller = AndroidWebViewController(id);
      widget.onWebViewCreated!(controller);
    }
  }
}

class AndroidWebViewController {
  final MethodChannel _channel;

  AndroidWebViewController(int id) 
      : _channel = MethodChannel('com.nocorps.in_app_browser/webview_$id');

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
}