class InAppBrowserSettings {
  final bool javaScriptEnabled;
  final bool domStorageEnabled;
  final bool databaseEnabled;
  final bool useWideViewPort;
  final bool allowFileAccess;
  final bool allowContentAccess;
  final bool loadWithOverviewMode;
  final bool allowsInlineMediaPlayback;
  final bool allowsBackForwardNavigationGestures;
  final bool allowFullscreen;
  final bool verticalScrollBarEnabled;
  final bool horizontalScrollBarEnabled;
  final bool disableVerticalScroll;
  final bool disableHorizontalScroll;
  
  InAppBrowserSettings({
    this.javaScriptEnabled = true,
    this.domStorageEnabled = true,
    this.databaseEnabled = true,
    this.useWideViewPort = true,
    this.allowFileAccess = true,
    this.allowContentAccess = true,
    this.loadWithOverviewMode = true,
    this.allowsInlineMediaPlayback = true,
    this.allowsBackForwardNavigationGestures = true,
    this.allowFullscreen = true,
    this.verticalScrollBarEnabled = true,
    this.horizontalScrollBarEnabled = true,
    this.disableVerticalScroll = false,
    this.disableHorizontalScroll = false,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'javaScriptEnabled': javaScriptEnabled,
      'domStorageEnabled': domStorageEnabled,
      'databaseEnabled': databaseEnabled,
      'useWideViewPort': useWideViewPort,
      'allowFileAccess': allowFileAccess,
      'allowContentAccess': allowContentAccess,
      'loadWithOverviewMode': loadWithOverviewMode,
      'allowsInlineMediaPlayback': allowsInlineMediaPlayback,
      'allowsBackForwardNavigationGestures': allowsBackForwardNavigationGestures,
      'allowFullscreen': allowFullscreen,
      'verticalScrollBarEnabled': verticalScrollBarEnabled,
      'horizontalScrollBarEnabled': horizontalScrollBarEnabled,
      'disableVerticalScroll': disableVerticalScroll,
      'disableHorizontalScroll': disableHorizontalScroll,
    };
  }
}