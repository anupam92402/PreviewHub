import 'package:flutter/material.dart';

import '../util/preview_hub_theme.dart';
import 'preview_hub_theme_controller.dart';

/// Applies the gallery's theme to [child], following [controller]. Also
/// publishes the controller to the subtree, so a screen that pushes a further
/// route can pass it along without holding it as a field of its own.
class PreviewHubTheming extends StatelessWidget {
  /// Themes [child] according to [controller].
  const PreviewHubTheming({
    required this.controller,
    required this.child,
    super.key,
  });

  /// Source of the current mode; null leaves the ambient theme alone.
  final PreviewHubThemeController? controller;

  /// Subtree to theme.
  final Widget child;

  /// The controller theming [context], or null outside the gallery. Read
  /// without subscribing: callers want the controller to hand on, not to
  /// rebuild when the mode changes.
  static PreviewHubThemeController? controllerOf(BuildContext context) =>
      context
          .getInheritedWidgetOfExactType<_PreviewHubThemeScope>()
          ?.controller;

  @override
  Widget build(BuildContext context) {
    final PreviewHubThemeController? controller = this.controller;

    return _PreviewHubThemeScope(
      controller: controller,
      child: controller == null
          ? child
          : ValueListenableBuilder<ThemeMode>(
              valueListenable: controller,
              builder: (BuildContext context, ThemeMode mode, Widget? child) =>
                  Theme(
                    data: _isDark(context, mode)
                        ? PreviewHubTheme.dark()
                        : PreviewHubTheme.light(),
                    child: child!,
                  ),
              child: child,
            ),
    );
  }

  bool _isDark(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark,
  };
}

/// Carries the gallery's theme controller down a route's subtree.
class _PreviewHubThemeScope extends InheritedWidget {
  const _PreviewHubThemeScope({required this.controller, required super.child});

  /// Controller handed to [PreviewHubTheming.controllerOf] callers.
  final PreviewHubThemeController? controller;

  @override
  bool updateShouldNotify(_PreviewHubThemeScope oldWidget) =>
      oldWidget.controller != controller;
}
