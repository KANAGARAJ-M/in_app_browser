# in_app_browser

A lightweight, customizable in-app browser for Flutter. This package provides a native-feeling, Instagram-style browser experience with smooth animations, gesture controls, and a modern UI—**all without external dependencies**.

---

## Features

- **No external dependencies:** Uses only Flutter and native platform code.
- **Instagram-style UI:** Slide-up transition, drag-to-dismiss, and modern toolbar.
- **Customizable:** Change colors, show/hide controls, enable/disable sharing, refresh, and navigation.
- **Cross-platform:** Android, iOS, and Web support. Desktop (macOS, Windows, Linux) coming soon.
- **Full browser controls:** Back, forward, reload, share, copy link, open in external browser.
- **Progress indicator:** Shows page loading progress.
- **Secure indicator:** Shows lock icon for HTTPS URLs.
- **Easy integration:** Simple API for opening URLs in-app.
- **Mocking support:** Built-in mock webview for testing environments.

---

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  in_app_browser: ^0.0.1
```

Import it in your Dart code:

```dart
import 'package:in_app_browser/in_app_browser.dart';
```

---

## Usage

### Quick Start

Open a URL in the in-app browser:

```dart
InAppBrowser.open(
  context,
  'https://flutter.dev',
);
```

### Customization

You can customize the browser's appearance and controls:

```dart
InAppBrowser.open(
  context,
  'https://flutter.dev',
  title: 'Flutter',
  backgroundColor: Colors.white,
  foregroundColor: Colors.deepPurple,
  showProgressBar: true,
  enableShare: true,
  enableRefresh: true,
  enableBackForward: true,
);
```

### Advanced: Use as a Widget

Embed the browser directly in your widget tree:

```dart
InAppBrowser(
  initialUrl: 'https://flutter.dev',
  title: 'Flutter',
  backgroundColor: Colors.white,
  foregroundColor: Colors.deepPurple,
  showControls: true,
  showProgressBar: true,
  enableShare: true,
  enableRefresh: true,
  enableBackForward: true,
  onClosed: () {
    print('Browser closed');
  },
)
```

### WebView Settings

Configure advanced WebView settings:

```dart
import 'package:in_app_browser/in_app_browser.dart';

final settings = InAppBrowserSettings(
  javascriptEnabled: true,
  domStorageEnabled: true,
  databaseEnabled: true,
  useWideViewPort: true,
  allowFileAccess: true,
  allowContentAccess: true,
  loadWithOverviewMode: true,
);

InAppBrowser(
  initialUrl: 'https://flutter.dev',
  settings: settings,
);
```

---

## API Reference

### `InAppBrowser.open`

```dart
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
  }
)
```

### `InAppBrowser` Widget

| Parameter           | Type                   | Description                                      |
|---------------------|------------------------|--------------------------------------------------|
| `initialUrl`        | String                 | The URL to load                                  |
| `title`             | String?                | Optional toolbar title                           |
| `backgroundColor`   | Color?                 | Toolbar/background color                         |
| `foregroundColor`   | Color?                 | Icon/text color                                  |
| `showControls`      | bool                   | Show/hide toolbar                                |
| `showProgressBar`   | bool                   | Show/hide progress bar                           |
| `enableShare`       | bool                   | Enable share menu                                |
| `enableRefresh`     | bool                   | Enable refresh button                            |
| `enableBackForward` | bool                   | Enable back/forward navigation                   |
| `settings`          | InAppBrowserSettings?  | Advanced WebView settings                        |
| `onClosed`          | VoidCallback?          | Called when browser is closed                    |

---

## Platform Support

| Android | iOS | Web | macOS | Windows | Linux |
|:-------:|:---:|:---:|:-----:|:-------:|:-----:|
|   ✅    | ✅  | ✅  |  🚧   |   🚧    |  🚧   |

✅ = Fully supported  
🚧 = Under development  

---

## Example

See the [`example/`](example/) directory for a complete Flutter app using this package.

---

## Testing

Enable test mode to use mock implementations in your tests:

```dart
import 'package:in_app_browser/src/platform_view/platform_view_factory.dart';

setUp(() {
  PlatformViewFactory.testMode = true;
});
```

---

## Contributing

Contributions are welcome! Please open issues or pull requests on [GitHub](https://github.com/KANAGARAJ-M/in_app_browser).

---

## Donation

If you find this package useful, consider supporting its development:

- [Buy Me a Coffee](https://coff.ee/MkrCreations)

---

## License

MIT License. See [LICENSE](LICENSE).

---

## Contact

For questions or support, please open an issue on [GitHub](https://github.com/KANAGARAJ-M/in_app_browser)
