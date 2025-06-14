import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_browser/src/in_app_browser_settings.dart';

void main() {
  group('InAppBrowserSettings', () {
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
}