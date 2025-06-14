import Flutter
import UIKit
import WebKit

public class InAppBrowserPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.nocorps.in_app_browser", binaryMessenger: registrar.messenger())
    let instance = InAppBrowserPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    registrar.register(
      WebViewFactory(messenger: registrar.messenger()),
      withId: "com.nocorps.in_app_browser/webview")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

class WebViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return FlutterWebView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args as? [String: Any],
      messenger: messenger)
  }
}

class FlutterWebView: NSObject, FlutterPlatformView, WKNavigationDelegate, WKUIDelegate {
  private let webView: WKWebView
  private let methodChannel: FlutterMethodChannel

  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: [String: Any]?,
    messenger: FlutterBinaryMessenger
  ) {
    let configuration = WKWebViewConfiguration()
    webView = WKWebView(frame: frame, configuration: configuration)
    methodChannel = FlutterMethodChannel(name: "com.nocorps.in_app_browser/webview_\(viewId)", binaryMessenger: messenger)
    
    super.init()
    
    // Apply settings
    if let settings = args?["settings"] as? [String: Any] {
      applySettings(settings)
    }
    
    // Setup delegates
    webView.navigationDelegate = self
    webView.uiDelegate = self
    
    // Load initial URL
    if let initialUrl = args?["initialUrl"] as? String, let url = URL(string: initialUrl) {
      webView.load(URLRequest(url: url))
    }
    
    // Handle method calls
    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      switch call.method {
      case "loadUrl":
        if let urlString = call.arguments as? [String: Any], 
           let urlToLoad = urlString["url"] as? String,
           let url = URL(string: urlToLoad) {
          self.webView.load(URLRequest(url: url))
          result(nil)
        } else {
          result(FlutterError(code: "MISSING_PARAMS", message: "URL is required", details: nil))
        }
        
      case "goBack":
        if self.webView.canGoBack {
          self.webView.goBack()
        }
        result(nil)
        
      case "goForward":
        if self.webView.canGoForward {
          self.webView.goForward()
        }
        result(nil)
        
      case "reload":
        self.webView.reload()
        result(nil)
        
      case "canGoBack":
        result(self.webView.canGoBack)
        
      case "canGoForward":
        result(self.webView.canGoForward)
        
      case "getCurrentUrl":
        result(self.webView.url?.absoluteString ?? "")
        
      case "getTitle":
        result(self.webView.title ?? "")
        
      case "evaluateJavascript":
        if let jsArg = call.arguments as? [String: Any], 
           let js = jsArg["javascript"] as? String {
          self.webView.evaluateJavaScript(js) { (value, error) in
            if let error = error {
              result(FlutterError(code: "JS_EVALUATION_ERROR", message: error.localizedDescription, details: nil))
            } else {
              result(value)
            }
          }
        } else {
          result(FlutterError(code: "MISSING_PARAMS", message: "JavaScript code is required", details: nil))
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView {
    return webView
  }
  
  private func applySettings(_ settings: [String: Any]) {
    if let allowsInlineMediaPlayback = settings["allowsInlineMediaPlayback"] as? Bool {
      webView.configuration.allowsInlineMediaPlayback = allowsInlineMediaPlayback
    }
    
    if let allowsBackForwardNavigationGestures = settings["allowsBackForwardNavigationGestures"] as? Bool {
      webView.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
    }
  }
  
  // MARK: - WKNavigationDelegate
  
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    methodChannel.invokeMethod("onLoadingStateChanged", arguments: ["isLoading": true])
    if let url = webView.url?.absoluteString {
      methodChannel.invokeMethod("onUrlChanged", arguments: ["url": url])
    }
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    methodChannel.invokeMethod("onLoadingStateChanged", arguments: ["isLoading": false])
    if let url = webView.url?.absoluteString {
      methodChannel.invokeMethod("onUrlChanged", arguments: ["url": url])
    }
    if let title = webView.title {
      methodChannel.invokeMethod("onTitleChanged", arguments: ["title": title])
    }
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    methodChannel.invokeMethod("onLoadingStateChanged", arguments: ["isLoading": false])
  }
  
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    methodChannel.invokeMethod("onLoadingStateChanged", arguments: ["isLoading": false])
  }
}