import 'package:flutter/material.dart';

/// Holds the gallery's light/dark choice.
class PreviewHubThemeController extends ValueNotifier<ThemeMode> {
  /// Starts in [mode], following the platform by default.
  PreviewHubThemeController([super.mode = ThemeMode.system]);

  /// Flips to whichever theme is not currently showing.
  void toggle(Brightness current) =>
      value = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
}
