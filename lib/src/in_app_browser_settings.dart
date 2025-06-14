class InAppBrowserSettings {
  final bool javascriptEnabled;
  final bool domStorageEnabled;
  final bool databaseEnabled;
  final bool useWideViewPort;
  final bool allowFileAccess;
  final bool allowContentAccess;
  final bool loadWithOverviewMode;

  const InAppBrowserSettings({
    this.javascriptEnabled = true,
    this.domStorageEnabled = true,
    this.databaseEnabled = true,
    this.useWideViewPort = true,
    this.allowFileAccess = true,
    this.allowContentAccess = true,
    this.loadWithOverviewMode = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'javascriptEnabled': javascriptEnabled,
      'domStorageEnabled': domStorageEnabled,
      'databaseEnabled': databaseEnabled,
      'useWideViewPort': useWideViewPort,
      'allowFileAccess': allowFileAccess,
      'allowContentAccess': allowContentAccess,
      'loadWithOverviewMode': loadWithOverviewMode,
    };
  }
}