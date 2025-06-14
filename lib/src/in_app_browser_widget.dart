import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'in_app_browser_controller.dart';
import 'in_app_browser_settings.dart';
import 'platform_view/platform_view_factory.dart';

class InAppBrowser extends StatefulWidget {
  final String initialUrl;
  final String? title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showProgressBar;
  final bool enableShare;
  final bool enableRefresh;
  final bool enableBackForward;
  final bool showControls;
  final VoidCallback? onClosed;

  const InAppBrowser({
    super.key,
    required this.initialUrl,
    this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.showProgressBar = true,
    this.enableShare = true,
    this.enableRefresh = true,
    this.enableBackForward = true,
    this.showControls = true,
    this.onClosed,
  });

  /// Opens the browser as a modal bottom sheet
  static Future<void> open(
    BuildContext context,
    String url, {
    String? title,
    Color? backgroundColor,
    Color? foregroundColor,
    bool showProgressBar = true,
    bool enableShare = true,
    bool enableRefresh = true,
    bool enableBackForward = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InAppBrowser(
        initialUrl: url,
        title: title,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        showProgressBar: showProgressBar,
        enableShare: enableShare,
        enableRefresh: enableRefresh,
        enableBackForward: enableBackForward,
        onClosed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<InAppBrowser> createState() => _InAppBrowserState();
}

class _InAppBrowserState extends State<InAppBrowser> {
  late InAppBrowserController _controller;
  String _currentUrl = '';
  String _title = '';
  double _progress = 0;
  bool _isSecure = false;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _title = widget.title ?? '';
  }

  void _onWebViewCreated(dynamic controller) {
    _controller = InAppBrowserController(controller);
    _controller.loadUrl(widget.initialUrl);
    
    _controller.onPageStarted = (url) {
      setState(() {
        _currentUrl = url;
      });
    };
    
    _controller.onPageFinished = (url) {
      setState(() {
        _currentUrl = url;
        _isSecure = url.startsWith('https://');
      });
      _updateNavigationState();
    };
    
    _controller.onProgressChanged = (progress) {
      setState(() {
        _progress = progress;
      });
    };
    
    _controller.onTitleChanged = (title) {
      setState(() {
        _title = title.isNotEmpty ? title : (widget.title ?? '');
      });
    };
  }

  Future<void> _updateNavigationState() async {
    final canGoBack = await _controller.canGoBack();
    final canGoForward = await _controller.canGoForward();
    
    if (mounted) {
      setState(() {
        _canGoBack = canGoBack;
        _canGoForward = canGoForward;
      });
    }
  }

  void _onBackPressed() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      _onCloseBrowser();
    }
  }

  void _onForwardPressed() {
    _controller.goForward();
  }

  void _onReloadPressed() {
    _controller.reload();
  }

  void _onCloseBrowser() {
    if (widget.onClosed != null) {
      widget.onClosed!();
    }
  }
  
  void _copyUrl() async {
    // Copy current URL to clipboard
    // You'll need to add clipboard package dependency
    try {
      await FlutterClipboard.copy(_currentUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL copied to clipboard')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to copy: $e')),
        );
      }
    }
  }
  
  void _openInExternalBrowser() async {
    // Open URL in external browser
    // You'll need to add url_launcher package dependency
    final url = Uri.parse(_currentUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open browser: $e')),
        );
      }
    }
  }

  void _shareUrl() async {
    // Share current URL
    // You'll need to add share_plus package dependency
    try {
      await Share.share(_currentUrl, subject: 'Check out this link');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;
    final foregroundColor = widget.foregroundColor ?? theme.colorScheme.primary;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: _onCloseBrowser,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title.isNotEmpty ? _title : _currentUrl,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    if (_isSecure) 
                      const Icon(Icons.lock, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _currentUrl,
                        style: TextStyle(
                          fontSize: 12,
                          color: foregroundColor.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'copy':
                      _copyUrl();
                      break;
                    case 'open':
                      _openInExternalBrowser();
                      break;
                    case 'share':
                      _shareUrl();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 20),
                        SizedBox(width: 8),
                        Text('Copy link'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'open',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_browser, size: 20),
                        SizedBox(width: 8),
                        Text('Open in browser'),
                      ],
                    ),
                  ),
                  if (widget.enableShare)
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              if (widget.showProgressBar && _progress < 1.0)
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: backgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              Expanded(
                child: PlatformViewFactory.createPlatformView(
                  initialUrl: widget.initialUrl,
                  settings: InAppBrowserSettings(
                    javascriptEnabled: true,
                    domStorageEnabled: true,
                    databaseEnabled: true,
                    useWideViewPort: true,
                    allowFileAccess: true,
                    allowContentAccess: true,
                    loadWithOverviewMode: true,
                  ),
                  onWebViewCreated: _onWebViewCreated,
                ),
              ),
              if (widget.showControls)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.enableBackForward)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: _canGoBack ? _onBackPressed : null,
                          color: _canGoBack ? foregroundColor : Colors.grey,
                        ),
                      if (widget.enableBackForward)
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: _canGoForward ? _onForwardPressed : null,
                          color: _canGoForward ? foregroundColor : Colors.grey,
                        ),
                      if (widget.enableRefresh)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _onReloadPressed,
                          color: foregroundColor,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}