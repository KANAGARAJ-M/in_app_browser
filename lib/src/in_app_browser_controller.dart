class InAppBrowserController {
  final dynamic _platformController;
  
  // Callbacks
  Function(String)? onPageStarted;
  Function(String)? onPageFinished;
  Function(double)? onProgressChanged;
  Function(String)? onTitleChanged;

  InAppBrowserController(this._platformController);

  Future<void> loadUrl(String url) async {
    await _platformController.loadUrl(url);
  }

  Future<void> goBack() async {
    await _platformController.goBack();
  }

  Future<void> goForward() async {
    await _platformController.goForward();
  }

  Future<void> reload() async {
    await _platformController.reload();
  }

  Future<bool> canGoBack() async {
    return await _platformController.canGoBack();
  }

  Future<bool> canGoForward() async {
    return await _platformController.canGoForward();
  }

  Future<String> getCurrentUrl() async {
    return await _platformController.getCurrentUrl();
  }

  Future<String> getTitle() async {
    return await _platformController.getTitle();
  }

  Future<String> evaluateJavascript(String javascript) async {
    return await _platformController.evaluateJavascript(javascript);
  }
}