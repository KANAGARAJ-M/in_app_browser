import 'package:flutter/material.dart';
import 'package:flutter_in_app_browser/flutter_in_app_browser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In-App Browser Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final textController = TextEditingController(text: 'https://flutter.dev');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In-App Browser Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                InAppBrowser.open(
                  context,
                  textController.text,
                  title: 'Flutter',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                );
              },
              child: const Text('Open URL'),
            ),
            const SizedBox(height: 16),
            const Text('Advanced Usage:'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmbeddedBrowserDemo(),
                  ),
                );
              },
              child: const Text('Try Embedded Browser'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmbeddedBrowserDemo extends StatelessWidget {
  const EmbeddedBrowserDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Embedded Browser'),
      ),
      body: const InAppBrowser(
        initialUrl: 'https://flutter.dev',
        title: 'Flutter',
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        showControls: true,
        showProgressBar: true,
        enableShare: true,
        enableRefresh: true,
        enableBackForward: true,
      ),
    );
  }
}
