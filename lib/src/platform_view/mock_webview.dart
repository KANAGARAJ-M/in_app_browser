import 'package:flutter/material.dart';
import '../in_app_browser_settings.dart';
import 'platform_view_factory.dart';

class MockWebView extends StatefulWidget {
  final String initialUrl;
  final InAppBrowserSettings settings;
  final WebViewCreatedCallback? onWebViewCreated;

  const MockWebView({
    super.key,
    required this.initialUrl,
    required this.settings,
    this.onWebViewCreated,
  });

  @override
  State<MockWebView> createState() => _MockWebViewState();
}

class _MockWebViewState extends State<MockWebView> {
  late final MockWebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MockWebViewController();
    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated!(_controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text('Mock WebView: ${widget.initialUrl}'),
      ),
    );
  }
}

class MockWebViewController {
  String _currentUrl = '';
  final String _title = 'Mock Page';
  bool _canGoBack = false;
  bool _canGoForward = false;
  
  // Callbacks
  Function(String)? onPageStarted;
  Function(String)? onPageFinished;
  Function(double)? onProgressChanged;
  Function(String)? onTitleChanged;

  MockWebViewController() {
    // Simulate progress reporting
    Future.delayed(const Duration(milliseconds: 100), () {
      if (onProgressChanged != null) onProgressChanged!(0.3);
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (onProgressChanged != null) onProgressChanged!(0.7);
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (onPageStarted != null) onPageStarted!('https://example.com');
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (onProgressChanged != null) onProgressChanged!(1.0);
      if (onPageFinished != null) onPageFinished!('https://example.com');
      if (onTitleChanged != null) onTitleChanged!('Example Domain');
    });
  }

  Future<void> loadUrl(String url) async {
    _currentUrl = url;
    
    if (onPageStarted != null) onPageStarted!(url);
    if (onProgressChanged != null) onProgressChanged!(0.1);
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (onProgressChanged != null) onProgressChanged!(0.5);
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (onProgressChanged != null) onProgressChanged!(1.0);
    if (onPageFinished != null) onPageFinished!(url);
    if (onTitleChanged != null) onTitleChanged!('Page: $url');
    
    _canGoBack = true;
  }

  Future<void> goBack() async {
    if (_canGoBack) {
      _canGoBack = false;
      _currentUrl = 'https://previous.example.com';
      
      if (onPageStarted != null) onPageStarted!(_currentUrl);
      if (onProgressChanged != null) onProgressChanged!(0.5);
      await Future.delayed(const Duration(milliseconds: 200));
      if (onPageFinished != null) onPageFinished!(_currentUrl);
      if (onTitleChanged != null) onTitleChanged!('Previous Page');
      
      _canGoForward = true;
    }
  }

  Future<void> goForward() async {
    if (_canGoForward) {
      _canGoForward = false;
      _currentUrl = 'https://example.com';
      
      if (onPageStarted != null) onPageStarted!(_currentUrl);
      if (onProgressChanged != null) onProgressChanged!(0.5);
      await Future.delayed(const Duration(milliseconds: 200));
      if (onPageFinished != null) onPageFinished!(_currentUrl);
      if (onTitleChanged != null) onTitleChanged!('Example Domain');
      
      _canGoBack = true;
    }
  }

  Future<void> reload() async {
    if (onPageStarted != null) onPageStarted!(_currentUrl);
    if (onProgressChanged != null) onProgressChanged!(0.2);
    await Future.delayed(const Duration(milliseconds: 200));
    if (onProgressChanged != null) onProgressChanged!(1.0);
    if (onPageFinished != null) onPageFinished!(_currentUrl);
  }

  Future<bool> canGoBack() async => _canGoBack;

  Future<bool> canGoForward() async => _canGoForward;

  Future<String> getCurrentUrl() async => _currentUrl;

  Future<String> getTitle() async => _title;

  Future<String> evaluateJavascript(String javascript) async {
    return '{"result": "mock result"}';
  }
}