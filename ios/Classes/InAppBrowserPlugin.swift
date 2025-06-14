import Flutter
import UIKit
import WebKit

public class InAppBrowserPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = InAppBrowserViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "com.nocorps.in_app_browser/webview")
  }
}

class InAppBrowserViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    return InAppBrowserView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args as? [String: Any],
      messenger: messenger
    )
  }

  public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

class InAppBrowserView: NSObject, FlutterPlatformView, WKNavigationDelegate, WKUIDelegate {
  private let webView: WKWebView
  private let methodChannel: FlutterMethodChannel
  private var progressObservation: NSKeyValueObservation?

  init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: [String: Any]?, messenger: FlutterBinaryMessenger) {
    let configuration = WKWebViewConfiguration()
    webView = WKWebView(frame: frame, configuration: configuration)
    methodChannel = FlutterMethodChannel(name: "com.nocorps.in_app_browser/webview_\(viewId)", binaryMessenger: messenger)
    
    super.init()
    
    // Set delegates
    webView.navigationDelegate = self
    webView.uiDelegate = self
    
    // Apply settings if provided
    if let settings = args?["settings"] as? [String: Any] {
      applySettings(settings)
    }
    
    // Load initial URL if provided
    if let initialUrl = args?["initialUrl"] as? String {
      if let url = URL(string: initialUrl) {
        webView.load(URLRequest(url: url))
      }
    }
    
    // Set up progress observer
    progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
      guard let self = self else { return }
      self.methodChannel.invokeMethod("onProgressChanged", arguments: ["progress": webView.estimatedProgress])
    }
    
    // Set up method channel handler
    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      self.handleMethodCall(call, result: result)
    }
  }

  func view() -> UIView {
    return webView
  }
  
  private func applySettings(_ settings: [String: Any]) {
    if let javaScriptEnabled = settings["javascriptEnabled"] as? Bool {
      webView.configuration.preferences.javaScriptEnabled = javaScriptEnabled
    }
    
    // For other WKWebView settings
    if let contentMode = settings["useWideViewPort"] as? Bool, contentMode {
      webView.configuration.preferences.setValue(true, forKey: "allowsContentJavaScript")
    }
  }
  
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "loadUrl":
      if let args = call.arguments as? [String: Any], let urlString = args["url"] as? String {
        if let url = URL(string: urlString) {
          webView.load(URLRequest(url: url))
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_URL", message: "The URL is invalid", details: nil))
        }
      } else {
        result(FlutterError(code: "MISSING_PARAMS", message: "URL is required", details: nil))
      }
      
    case "goBack":
      if webView.canGoBack {
        webView.goBack()
      }
      result(nil)
      
    case "goForward":
      if webView.canGoForward {
        webView.goForward()
      }
      result(nil)
      
    case "reload":
      webView.reload()
      result(nil)
      
    case "canGoBack":
      result(webView.canGoBack)
      
    case "canGoForward":
      result(webView.canGoForward)
      
    case "getCurrentUrl":
      result(webView.url?.absoluteString ?? "")
      
    case "getTitle":
      result(webView.title ?? "")
      
    case "evaluateJavascript":
      if let args = call.arguments as? [String: Any], let javaScript = args["javascript"] as? String {
        webView.evaluateJavaScript(javaScript) { (value, error) in
          if let error = error {
            result(FlutterError(code: "JS_ERROR", message: error.localizedDescription, details: nil))
          } else {
            if let stringValue = value as? String {
              result(stringValue)
            } else if let value = value {
              result("\(value)")
            } else {
              result("")
            }
          }
        }
      } else {
        result(FlutterError(code: "MISSING_PARAMS", message: "JavaScript code is required", details: nil))
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - WKNavigationDelegate
  
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    methodChannel.invokeMethod("onPageStarted", arguments: ["url": webView.url?.absoluteString ?? ""])
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    methodChannel.invokeMethod("onPageFinished", arguments: ["url": webView.url?.absoluteString ?? ""])
    methodChannel.invokeMethod("onTitleChanged", arguments: ["title": webView.title ?? ""])
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    methodChannel.invokeMethod("onPageFinished", arguments: ["url": webView.url?.absoluteString ?? ""])
  }
  
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    methodChannel.invokeMethod("onPageFinished", arguments: ["url": webView.url?.absoluteString ?? ""])
  }
  
  // MARK: - Cleanup
  
  deinit {
    progressObservation?.invalidate()