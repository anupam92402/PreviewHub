import 'package:flutter/material.dart';
import 'package:preview_hub/preview_hub.dart';

import 'network_assets.dart';

void main() => runApp(const ExampleApp());

/// Ordinary client app; its bundled assets are what the gallery will preview.
class ExampleApp extends StatelessWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Preview Hub Example',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
    ),
    home: const CounterPage(title: 'Preview Hub Example'),
  );
}

/// Counter screen standing in for the client's own UI.
class CounterPage extends StatefulWidget {
  /// Creates the counter screen.
  const CounterPage({required this.title, super.key});

  /// Label shown in the app bar.
  final String title;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  void _openPreviewHub() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const PreviewHubDashboard(
          config: PreviewHubConfig(networkImages: allNetworkImages),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'open-preview-hub',
        onPressed: _openPreviewHub,
        icon: const Icon(Icons.grid_view_rounded),
        label: const Text('Preview Hub'),
      ),
    );
  }
}
