import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'in_app_browser_controller.dart';
import 'in_app_browser_settings.dart';
import 'platform_view/platform_view_factory.dart';

class InAppBrowser extends StatefulWidget {
  final String initialUrl;
  final String? title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showControls;
  final bool showProgressBar;
  final bool enableShare;
  final bool enableRefresh;
  final bool enableBackForward;
  final VoidCallback? onClosed;
  
  const InAppBrowser({
    super.key,
    required this.initialUrl,
    this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.showControls = true,
    this.showProgressBar = true,
    this.enableShare = true,
    this.enableRefresh = true,
    this.enableBackForward = true,
    this.onClosed,
  });

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
  }) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => InAppBrowser(
          initialUrl: url,
          title: title,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          showProgressBar: showProgressBar,
          enableShare: enableShare,
          enableRefresh: enableRefresh,
          enableBackForward: enableBackForward,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  State<InAppBrowser> createState() => _InAppBrowserState();
}

class _InAppBrowserState extends State<InAppBrowser> with TickerProviderStateMixin {
  final InAppBrowserController _controller = InAppBrowserController();
  String _currentUrl = '';
  String _pageTitle = '';
  bool _isLoading = true;
  double _progress = 0.0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _isSecure = false;
  
  // Animation controllers
  late AnimationController _toolbarAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _toolbarAnimation;
  
  // Gesture tracking
  bool _isDragging = false;
  double _dragDistance = 0.0;
  double _startDragY = 0.0;
  static const double _dismissThreshold = 150.0;
  static const double _dragSensitivity = 20.0;
  
  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _pageTitle = widget.title ?? 'Loading...';
    
    // Initialize animation controllers
    _toolbarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _toolbarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _toolbarAnimationController, curve: Curves.easeInOut),
    );
    
    // Setup listeners
    _setupListeners();
    
    // Start animations
    _toolbarAnimationController.forward();
    
    // Load the URL
    _loadUrl();
  }
  
  void _setupListeners() {
    _controller.onUrlChanged.listen((url) {
      setState(() {
        _currentUrl = url;
        _isSecure = url.startsWith('https://');
      });
    });
    
    _controller.onTitleChanged.listen((title) {
      setState(() {
        _pageTitle = title.isNotEmpty ? title : _extractDomainFromUrl(_currentUrl);
      });
    });
    
    _controller.onProgressChanged.listen((progress) {
      setState(() {
        _progress = progress;
      });
      
      if (progress >= 1.0) {
        _progressAnimationController.reverse();
      } else {
        _progressAnimationController.forward();
      }
    });
    
    _controller.onLoadingStateChanged.listen((isLoading) {
      setState(() {
        _isLoading = isLoading;
      });
      _updateNavigationState();
    });
  }
  
  Future<void> _loadUrl() async {
    try {
      await _controller.loadUrl(widget.initialUrl);
    } catch (e) {
      debugPrint('Failed to load URL: $e');
    }
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
  
  @override
  void dispose() {
    _controller.dispose();
    _toolbarAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;
    final foregroundColor = widget.foregroundColor ?? theme.primaryColor;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Main WebView Container
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + (widget.showControls ? 100 : 0),
            ),
            child: Column(
              children: [
                // Progress bar
                if (widget.showProgressBar && _isLoading)
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                
                // WebView
                Expanded(
                  child: Transform.translate(
                    offset: Offset(0, _dragDistance * 0.3),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_dragDistance > 0 ? 12 : 0),
                        boxShadow: _dragDistance > 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: PlatformViewFactory.createPlatformView(
                        initialUrl: widget.initialUrl,
                        settings: InAppBrowserSettings(),
                        onWebViewCreated: (controller) {
                          // WebView was created, ready to use
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Toolbar
          if (widget.showControls)
            AnimatedBuilder(
              animation: _toolbarAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, (1 - _toolbarAnimation.value) * -100),
                child: GestureDetector(
                  onPanStart: (details) {
                    _isDragging = true;
                    _dragDistance = 0.0;
                    _startDragY = details.globalPosition.dy;
                  },
                  onPanUpdate: (details) {
                    if (_isDragging) {
                      double deltaY = details.globalPosition.dy - _startDragY;
                      
                      if (deltaY > _dragSensitivity) {
                        setState(() {
                          _dragDistance = deltaY - _dragSensitivity;
                        });
                        
                        if (_dragDistance > 50) {
                          _toolbarAnimationController.reverse();
                        }
                      }
                    }
                  },
                  onPanEnd: (details) {
                    _isDragging = false;
                    
                    if (_dragDistance > _dismissThreshold) {
                      Navigator.of(context).pop();
                      widget.onClosed?.call();
                    } else {
                      _toolbarAnimationController.forward();
                      setState(() {
                        _dragDistance = 0.0;
                      });
                    }
                  },
                  child: _buildTopToolbar(context, foregroundColor),
                ),
              ),
            ),
          
          // Drag indicator
          if (_dragDistance > 20)
            Positioned(
              top: MediaQuery.of(context).padding.top + 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTopToolbar(BuildContext context, Color foregroundColor) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 1,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row with close and actions
          Row(
            children: [
              // Close button
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onClosed?.call();
                },
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  foregroundColor: foregroundColor,
                ),
              ),
              
              // Title and URL
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Back button
                        if (widget.enableBackForward)
                          IconButton(
                            onPressed: _canGoBack ? () => _controller.goBack() : null,
                            icon: const Icon(Icons.arrow_back_ios),
                            iconSize: 16,
                            style: IconButton.styleFrom(
                              foregroundColor: _canGoBack ? foregroundColor : Colors.grey,
                              minimumSize: const Size(32, 32),
                              padding: const EdgeInsets.all(4),
                            ),
                          ),
                        
                        // Title (flexible to take remaining space)
                        Expanded(
                          child: Text(
                            _pageTitle,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        // Forward button
                        if (widget.enableBackForward)
                          IconButton(
                            onPressed: _canGoForward ? () => _controller.goForward() : null,
                            icon: const Icon(Icons.arrow_forward_ios),
                            iconSize: 16,
                            style: IconButton.styleFrom(
                              foregroundColor: _canGoForward ? foregroundColor : Colors.grey,
                              minimumSize: const Size(32, 32),
                              padding: const EdgeInsets.all(4),
                            ),
                          ),
                      ],
                    ),
                    
                    // URL row with refresh button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Refresh button
                        if (widget.enableRefresh)
                          IconButton(
                            onPressed: () => _controller.reload(),
                            icon: _isLoading 
                                ? SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                                    ),
                                  )
                                : const Icon(Icons.refresh),
                            iconSize: 14,
                            style: IconButton.styleFrom(
                              foregroundColor: foregroundColor,
                              minimumSize: const Size(28, 28),
                              padding: const EdgeInsets.all(2),
                            ),
                          ),
                        
                        // Security indicator
                        if (_isSecure) ...[
                          Icon(
                            Icons.lock,
                            size: 12,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 4),
                        ],
                        
                        // Domain URL
                        Expanded(
                          child: Text(
                            _extractDomainFromUrl(_currentUrl),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        // Spacer to balance the refresh button
                        if (widget.enableRefresh)
                          const SizedBox(width: 28),
                      ],
                    ),
                  ],
                ),
              ),
              
              // More options
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  if (widget.enableRefresh)
                    const PopupMenuItem(
                      value: 'refresh',
                      child: Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Refresh'),
                        ],
                      ),
                    ),
                  if (widget.enableShare)
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Copy Link'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'external',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_browser),
                        SizedBox(width: 8),
                        Text('Open in Browser'),
                      ],
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _handleMenuAction(String action) async {
    switch (action) {
      case 'refresh':
        _controller.reload();
        break;
      case 'share':
        _shareUrl();
        break;
      case 'copy':
        _copyUrl();
        break;
      case 'external':
        _openInExternalBrowser();
        break;
    }
  }
  
  void _shareUrl() {
    // Native sharing would require platform channel implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share: $_currentUrl')),
    );
  }
  
  void _copyUrl() {
    Clipboard.setData(ClipboardData(text: _currentUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard')),
    );
  }
  
  void _openInExternalBrowser() async {
    // This would be implemented via platform channels
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening in external browser')),
    );
  }
  
  String _extractDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty ? uri.host : url;
    } catch (e) {
      if (url.length > 50) {
        return '${url.substring(0, 47)}...';
      }
      return url;
    }
  }
}