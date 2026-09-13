import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

/// Host app that runs the gallery shipped by `preview_hub`.
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
    home: const _Placeholder(),
  );
}

/// Stands in until the package exposes its gallery.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Preview Hub Example')),
    body: const Center(child: Text('Wire the gallery in here.')),
  );
}
