import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_browser/src/in_app_browser_widget.dart';
import 'package:in_app_browser/src/in_app_browser_settings.dart';
import 'package:in_app_browser/src/platform_view/android_webview.dart';
import 'package:in_app_browser/src/platform_view/platform_view_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Enable test mode for platform view factory
  setUp(() {
    PlatformViewFactory.testMode = true;
  });

  group('InAppBrowserSettings Tests', () {
    test('should create settings with default values', () {
      final settings = InAppBrowserSettings();
      
      expect(settings.javascriptEnabled, true);
      expect(settings.domStorageEnabled, true);
      expect(settings.databaseEnabled, true);
      expect(settings.useWideViewPort, true);
      expect(settings.allowFileAccess, true);
      expect(settings.allowContentAccess, true);
      expect(settings.loadWithOverviewMode, true);
    });
    
    test('should create settings with custom values', () {
      final settings = InAppBrowserSettings(
        javascriptEnabled: false,
        domStorageEnabled: false,
        databaseEnabled: false,
        useWideViewPort: false,
        allowFileAccess: false,
        allowContentAccess: false,
        loadWithOverviewMode: false,
      );
      
      expect(settings.javascriptEnabled, false);
      expect(settings.domStorageEnabled, false);
      expect(settings.databaseEnabled, false);
      expect(settings.useWideViewPort, false);
      expect(settings.allowFileAccess, false);
      expect(settings.allowContentAccess, false);
      expect(settings.loadWithOverviewMode, false);
    });
    
    test('should convert settings to map correctly', () {
      final settings = InAppBrowserSettings();
      final map = settings.toMap();
      
      expect(map['javascriptEnabled'], true);
      expect(map['domStorageEnabled'], true);
      expect(map['databaseEnabled'], true);
      expect(map['useWideViewPort'], true);
      expect(map['allowFileAccess'], true);
      expect(map['allowContentAccess'], true);
      expect(map['loadWithOverviewMode'], true);
    });
  });

  group('AndroidWebViewController Tests', () {
    const MethodChannel channel = MethodChannel('com.nocorps.in_app_browser/webview_0');
    final List<MethodCall> log = <MethodCall>[];
    
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          log.add(methodCall);
          
          switch (methodCall.method) {
            case 'loadUrl':
              return null;
            case 'canGoBack':
              return true;
            case 'canGoForward':
              return false;
            case 'getCurrentUrl':
              return 'https://example.com';
            case 'getTitle':
              return 'Example Domain';
            case 'evaluateJavascript':
              return '{"result": "success"}';
            default:
              return null;
          }
        },
      );
      log.clear();
    });
    
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });
    
    test('controller should invoke method channel methods correctly', () async {
      final controller = AndroidWebViewController(0);
      
      await controller.loadUrl('https://flutter.dev');
      expect(log, hasLength(1));
      expect(log.first.method, 'loadUrl');
      expect(log.first.arguments['url'], 'https://flutter.dev');
      
      final canGoBack = await controller.canGoBack();
      expect(canGoBack, true);
      expect(log[1].method, 'canGoBack');
      
      final canGoForward = await controller.canGoForward();
      expect(canGoForward, false);
      expect(log[2].method, 'canGoForward');
      
      final currentUrl = await controller.getCurrentUrl();
      expect(currentUrl, 'https://example.com');
      expect(log[3].method, 'getCurrentUrl');
      
      final title = await controller.getTitle();
      expect(title, 'Example Domain');
      expect(log[4].method, 'getTitle');
      
      final jsResult = await controller.evaluateJavascript('document.title');
      expect(jsResult, '{"result": "success"}');
      expect(log[5].method, 'evaluateJavascript');
      expect(log[5].arguments['javascript'], 'document.title');
    });
    
    test('controller should handle callbacks correctly', () async {
      final controller = AndroidWebViewController(0);
      
      bool pageStartedCalled = false;
      bool pageFinishedCalled = false;
      bool progressChangedCalled = false;
      bool titleChangedCalled = false;
      
      String? startedUrl;
      String? finishedUrl;
      double? progress;
      String? title;
      
      controller.onPageStarted = (url) {
        pageStartedCalled = true;
        startedUrl = url;
      };
      
      controller.onPageFinished = (url) {
        pageFinishedCalled = true;
        finishedUrl = url;
      };
      
      controller.onProgressChanged = (p) {
        progressChangedCalled = true;
        progress = p;
      };
      
      controller.onTitleChanged = (t) {
        titleChangedCalled = true;
        title = t;
      };
      
      // Simulate platform callbacks
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(MethodCall('onPageStarted', {'url': 'https://flutter.dev'})),
        (ByteData? data) {},
      );
      
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(MethodCall('onPageFinished', {'url': 'https://flutter.dev'})),
        (ByteData? data) {},
      );
      
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(MethodCall('onProgressChanged', {'progress': 0.75})),
        (ByteData? data) {},
      );
      
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(MethodCall('onTitleChanged', {'title': 'Flutter'})),
        (ByteData? data) {},
      );
      
      expect(pageStartedCalled, true);
      expect(startedUrl, 'https://flutter.dev');
      
      expect(pageFinishedCalled, true);
      expect(finishedUrl, 'https://flutter.dev');
      
      expect(progressChangedCalled, true);
      expect(progress, 0.75);
      
      expect(titleChangedCalled, true);
      expect(title, 'Flutter');
    });
  });

  group('InAppBrowser Widget Tests', () {
    testWidgets('should render with correct initial properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppBrowser(
              initialUrl: 'https://example.com',
              title: 'Test Browser',
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              showProgressBar: true,
              enableShare: true,
              enableRefresh: true,
              enableBackForward: true,
            ),
          ),
        ),
      );
      
      // Pump several times to let animations complete
      await tester.pumpAndSettle();
      
      // Check for title text
      expect(find.text('Test Browser'), findsOneWidget);
      
      // Check for close button (should be visible)
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      // Check for mock WebView text - this is displayed by our MockWebView in test mode
      expect(find.text('Mock WebView: https://example.com'), findsOneWidget);
    });
    
    testWidgets('should hide controls when showControls is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppBrowser(
              initialUrl: 'https://example.com',
              showControls: false,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Navigation controls should not be visible
      expect(find.byIcon(Icons.arrow_back_ios), findsNothing);
      expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });
    
    testWidgets('should close browser when close button is tapped', (WidgetTester tester) async {
      bool closed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppBrowser(
              initialUrl: 'https://example.com',
              onClosed: () {
                closed = true;
              },
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      
      expect(closed, true);
    });
  });
}