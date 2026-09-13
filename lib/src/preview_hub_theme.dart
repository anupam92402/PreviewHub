import 'package:flutter/material.dart';

/// Material 3 themes the landing screen is designed against.
class PreviewHubTheme {
  const PreviewHubTheme._();

  /// Colour the scheme is generated from.
  static const Color seedColor = Color(0xFF6366F1);

  /// Theme used in light mode.
  static ThemeData light() => _build(Brightness.light);

  /// Theme used in dark mode.
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
