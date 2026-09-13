import 'package:flutter/material.dart';

import 'dashboard/preview_hub_dashboard.dart';
import 'preview_hub_strings.dart';
import 'preview_hub_theme.dart';

/// Runnable root for the gallery.
///
/// Owns the [MaterialApp], both themes and the light/dark toggle, so running
/// the gallery takes one line and no configuration:
///
/// ```dart
/// void main() => runApp(const PreviewHubApp());
/// ```
///
/// To mount the gallery inside an app that already has its own [MaterialApp] —
/// a hidden debug route, say — use [PreviewHubDashboard] directly and leave
/// `onThemeToggle` unset so the host's theme keeps control.
class PreviewHubApp extends StatefulWidget {
  /// Creates the runnable gallery.
  const PreviewHubApp({super.key});

  @override
  State<PreviewHubApp> createState() => _PreviewHubAppState();
}

class _PreviewHubAppState extends State<PreviewHubApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  /// Flips to whichever theme [context] is not currently showing.
  ///
  /// [context] has to come from below the [MaterialApp]: above it there is no
  /// [Theme] to read, so the brightness would always resolve to the light
  /// fallback and the gallery would never come back out of dark mode.
  void _toggleTheme(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    _themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (BuildContext context, ThemeMode mode, Widget? child) =>
          MaterialApp(
            title: PreviewHubStrings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: PreviewHubTheme.light(),
            darkTheme: PreviewHubTheme.dark(),
            themeMode: mode,
            home: Builder(
              builder: (BuildContext context) => PreviewHubDashboard(
                onThemeToggle: () => _toggleTheme(context),
              ),
            ),
          ),
    );
  }
}
