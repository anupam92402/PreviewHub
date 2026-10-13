import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';

/// Flips the gallery between the light and dark themes.
class DashboardThemeToggle extends StatelessWidget {
  /// Creates the toggle, calling [onPressed] when tapped.
  const DashboardThemeToggle({required this.onPressed, super.key});

  /// Called when the toggle is tapped.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton.filledTonal(
      tooltip: isDark
          ? PreviewHubStrings.themeToggleToLight
          : PreviewHubStrings.themeToggleToDark,
      onPressed: onPressed,
      iconSize: 18,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: scheme.surface.withValues(alpha: 0.7),
        foregroundColor: scheme.onSurfaceVariant,
      ),
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
    );
  }
}
