import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../in_app_browser_settings.dart';
import 'platform_view_factory.dart';

class WebWebView extends StatefulWidget {
  final String initialUrl;
  final InAppBrowserSettings settings;
  final WebViewCreatedCallback? onWebViewCreated;

  const WebWebView({
    super.key,
    required this.initialUrl,
    required this.settings,
    this.onWebViewCreated,
  });

  @override
  State<WebWebView> createState() => _WebWebViewState();
}

class _WebWebViewState extends State<WebWebView> {
  late final String _viewType;
  late final html.IFrameElement _iframeElement;

  @override
  void initState() {
    super.initState();
    _viewType = 'iframe-${DateTime.now().millisecondsSinceEpoch}';
    _iframeElement = html.IFrameElement()
      ..src = widget.initialUrl
      ..style.border = 'none'
      ..style.height = '100%'
      ..style.width = '100%'
      ..allowFullscreen = true;
    
    // Using registerViewFactory through JS interop
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _viewType, 
      (int viewId) => _iframeElement
    );

    if (widget.onWebViewCreated != null) {
      final controller = WebWebViewController(_iframeElement);
      widget.onWebViewCreated!(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: _viewType,
    );
  }
}

class WebWebViewController {
  final html.IFrameElement _iframeElement;
  
  // Callbacks
  Function(String)? onPageStarted;
  Function(String)? onPageFinished;
  Function(double)? onProgressChanged;
  Function(String)? onTitleChanged;

  WebWebViewController(this._iframeElement) {
    _setupListeners();
  }
  
  void _setupListeners() {
    _iframeElement.onLoad.listen((event) {
      if (onPageFinished != null) {
        onPageFinished!(_iframeElement.src ?? '');
      }
      if (onProgressChanged != null) {
        onProgressChanged!(1.0);
      }
      _updateTitle();
    });
    
    // We need to simulate some events that aren't directly available in iframes
    if (onProgressChanged != null) {
      // Simulate progress
      Future.delayed(const Duration(milliseconds: 100), () {
        onProgressChanged!(0.3);
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        onProgressChanged!(0.7);
      });
    }
    
    if (onPageStarted != null) {
      Future.delayed(const Duration(milliseconds: 50), () {
        onPageStarted!(_iframeElement.src ?? '');
      });
    }
  }
  
  void _updateTitle() {
    try {
      // This is the safer approach for getting document title
      final title = html.document.title;
      if (onTitleChanged != null) {
        onTitleChanged!(title);
      }
    } catch (e) {
      // Title might not be accessible due to CORS
      if (onTitleChanged != null) {
        onTitleChanged!('');
      }
    }
  }

  Future<void> loadUrl(String url) async {
    if (onPageStarted != null) {
      onPageStarted!(url);
    }
    if (onProgressChanged != null) {
      onProgressChanged!(0.1);
    }
    _iframeElement.src = url;
  }

  Future<void> goBack() async {
    html.window.history.back();
  }

  Future<void> goForward() async {
    html.window.history.forward();
  }

  Future<void> reload() async {
    final currentUrl = _iframeElement.src;
    if (currentUrl != null) {
      if (onPageStarted != null) {
        onPageStarted!(currentUrl);
      }
      if (onProgressChanged != null) {
        onProgressChanged!(0.1);
      }
      _iframeElement.src = currentUrl;
    }
  }

  Future<bool> canGoBack() async {
    return html.window.history.length > 1;
  }

  Future<bool> canGoForward() async {
    return false; // Not reliably detectable in web
  }

  Future<String> getCurrentUrl() async {
    return _iframeElement.src ?? '';
  }

  Future<String> getTitle() async {
    try {
      return html.document.title;
    } catch (e) {
      return '';
    }
  }

  Future<String> evaluateJavascript(String javascript) async {
    try {
      // Using callMethod approach for JS evaluation
      // ignore: undefined_method
      final result = html.window.callMethod('eval', [javascript]);
      return result?.toString() ?? '';
    } catch (e) {
      return '{"error": "JavaScript evaluation failed due to security restrictions"}';
    }
  }
}