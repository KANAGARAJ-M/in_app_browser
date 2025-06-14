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
      ..allowFullscreen = widget.settings.allowFullscreen;

    // Register the view
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

  WebWebViewController(this._iframeElement);

  void loadUrl(String url) {
    _iframeElement.src = url;
  }

  void goBack() {
    html.window.history.back();
  }

  void goForward() {
    html.window.history.forward();
  }

  void reload() {
    _iframeElement.src = _iframeElement.src;
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
    return ''; // Not reliably accessible from iframes
  }

  Future<void> evaluateJavascript(String javascript) async {
    // Not safely possible with iframes due to security restrictions
  }
}