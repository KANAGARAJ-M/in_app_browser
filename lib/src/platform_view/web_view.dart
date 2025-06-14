import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;
import '../in_app_browser_settings.dart';
import 'platform_view_factory.dart';

class WebView extends StatefulWidget {
  final String initialUrl;
  final InAppBrowserSettings settings;
  final WebViewCreatedCallback? onWebViewCreated;

  const WebView({
    super.key,
    required this.initialUrl,
    required this.settings,
    this.onWebViewCreated,
  });

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
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
    // Register the view
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType, 
      (int viewId) => _iframeElement
    );
    if (widget.onWebViewCreated != null) {
      final controller = WebViewController(_iframeElement);
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

class WebViewController {
  final html.IFrameElement _iframeElement;

  WebViewController(this._iframeElement);

  void loadUrl(String url) {
    _iframeElement.src = url;
  }

  // Add other methods as needed
}