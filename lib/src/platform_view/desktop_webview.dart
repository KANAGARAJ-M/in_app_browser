import 'package:flutter/material.dart';
import '../in_app_browser_settings.dart';
import 'platform_view_factory.dart';

class DesktopWebView extends StatefulWidget {
  final String initialUrl;
  final InAppBrowserSettings settings;
  final WebViewCreatedCallback? onWebViewCreated;

  const DesktopWebView({
    super.key,
    required this.initialUrl,
    required this.settings,
    this.onWebViewCreated,
  });

  @override
  State<DesktopWebView> createState() => _DesktopWebViewState();
}

class _DesktopWebViewState extends State<DesktopWebView> {
  @override
  Widget build(BuildContext context) {
    // For desktop, we need platform-specific implementations
    // This is a placeholder that shows a message until native implementation is added
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.web, size: 48),
          const SizedBox(height: 16),
          Text('Loading: ${widget.initialUrl}'),
          const SizedBox(height: 16),
          const Text('Desktop support requires platform-specific implementation'),
        ],
      ),
    );
  }
}