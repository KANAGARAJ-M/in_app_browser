package com.nocorps.in_app_browser

import android.content.Context
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebChromeClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class InAppBrowserPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
  private lateinit var channel: MethodChannel

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "com.nocorps.in_app_browser")
    channel.setMethodCallHandler(this)
    binding.platformViewRegistry.registerViewFactory(
      "com.nocorps.in_app_browser/webview", WebViewFactory(binding.binaryMessenger))
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

class WebViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    val creationParams = args as Map<String?, Any?>?
    return FlutterWebView(context, messenger, viewId, creationParams)
  }
}

class FlutterWebView(
  context: Context,
  messenger: BinaryMessenger,
  id: Int,
  creationParams: Map<String?, Any?>?
) : PlatformView, MethodChannel.MethodCallHandler {
  private val webView: WebView = WebView(context)
  private val methodChannel: MethodChannel = MethodChannel(messenger, "com.nocorps.in_app_browser/webview_$id")

  init {
    methodChannel.setMethodCallHandler(this)
    
    // Configure WebView
    webView.settings.apply {
      javaScriptEnabled = true
      domStorageEnabled = true
      databaseEnabled = true
      useWideViewPort = true
      loadWithOverviewMode = true
      allowFileAccess = true
      allowContentAccess = true
    }
    
    webView.webViewClient = object : WebViewClient() {
      override fun onPageStarted(view: WebView, url: String, favicon: Bitmap?) {
        methodChannel.invokeMethod("onLoadingStateChanged", mapOf("isLoading" to true))
        methodChannel.invokeMethod("onUrlChanged", mapOf("url" to url))
      }

      override fun onPageFinished(view: WebView, url: String) {
        methodChannel.invokeMethod("onLoadingStateChanged", mapOf("isLoading" to false))
        methodChannel.invokeMethod("onUrlChanged", mapOf("url" to url))
        webView.evaluateJavascript("document.title") { title ->
          val processedTitle = title?.replace("\"", "") ?: ""
          methodChannel.invokeMethod("onTitleChanged", mapOf("title" to processedTitle))
        }
      }
    }
    
    webView.webChromeClient = object : WebChromeClient() {
      override fun onProgressChanged(view: WebView, progress: Int) {
        methodChannel.invokeMethod("onProgressChanged", mapOf("progress" to progress / 100.0))
      }
    }
    
    // Load initial URL if provided
    val initialUrl = creationParams?.get("initialUrl") as? String
    if (initialUrl != null) {
      webView.loadUrl(initialUrl)
    }
    
    // Apply settings
    val settings = creationParams?.get("settings") as? Map<String, Any>
    if (settings != null) {
      applySettings(settings)
    }
  }

  private fun applySettings(settings: Map<String, Any>) {
    webView.settings.apply {
      settings["javaScriptEnabled"]?.let { javaScriptEnabled = it as Boolean }
      settings["domStorageEnabled"]?.let { domStorageEnabled = it as Boolean }
      settings["databaseEnabled"]?.let { databaseEnabled = it as Boolean }
      settings["useWideViewPort"]?.let { useWideViewPort = it as Boolean }
      settings["allowFileAccess"]?.let { allowFileAccess = it as Boolean }
      settings["allowContentAccess"]?.let { allowContentAccess = it as Boolean }
      settings["loadWithOverviewMode"]?.let { loadWithOverviewMode = it as Boolean }
    }
  }

  override fun getView(): View = webView

  override fun dispose() {
    methodChannel.setMethodCallHandler(null)
    webView.destroy()
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "loadUrl" -> {
        val url = call.argument<String>("url")
        if (url != null) {
          webView.loadUrl(url)
          result.success(null)
        } else {
          result.error("MISSING_PARAMS", "URL is required", null)
        }
      }
      "goBack" -> {
        if (webView.canGoBack()) {
          webView.goBack()
        }
        result.success(null)
      }
      "goForward" -> {
        if (webView.canGoForward()) {
          webView.goForward()
        }
        result.success(null)
      }
      "reload" -> {
        webView.reload()
        result.success(null)
      }
      "canGoBack" -> {
        result.success(webView.canGoBack())
      }
      "canGoForward" -> {
        result.success(webView.canGoForward())
      }
      "getCurrentUrl" -> {
        result.success(webView.url)
      }
      "getTitle" -> {
        result.success(webView.title)
      }
      "evaluateJavascript" -> {
        val javascript = call.argument<String>("javascript")
        if (javascript != null) {
          webView.evaluateJavascript(javascript) { value ->
            result.success(value)
          }
        } else {
          result.error("MISSING_PARAMS", "JavaScript code is required", null)
        }
      }
      else -> result.notImplemented()
    }
  }
}