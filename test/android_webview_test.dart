import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_browser/src/in_app_browser_settings.dart';
import 'package:in_app_browser/src/platform_view/android_webview.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AndroidWebView', () {
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
    });
  });
}