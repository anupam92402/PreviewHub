import 'package:flutter/material.dart';

import '../preview_hub_strings.dart';

/// Gradient hero at the top of the landing screen.
class DashboardHeader extends StatelessWidget {
  /// Creates the hero, with a theme toggle when [onThemeToggle] is given.
  const DashboardHeader({this.onThemeToggle, super.key});

  /// Called when the theme toggle is tapped; `null` hides it.
  final VoidCallback? onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const <double>[0, 0.55, 1],
          colors: <Color>[
            scheme.primary.withValues(alpha: 0.16),
            scheme.tertiary.withValues(alpha: 0.07),
            scheme.tertiary.withValues(alpha: 0),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -80,
            right: -60,
            child: _HeaderGlow(color: scheme.primary),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 28,
              20,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const _HeaderBadge(),
                    const Spacer(),
                    if (onThemeToggle != null)
                      _ThemeToggle(onPressed: onThemeToggle!),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  PreviewHubStrings.headline,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.15,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  PreviewHubStrings.subhead,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft halo that gives the hero some depth.
class _HeaderGlow extends StatelessWidget {
  const _HeaderGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 240,
    height: 240,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: <Color>[
          color.withValues(alpha: 0.20),
          color.withValues(alpha: 0),
        ],
      ),
    ),
  );
}

/// Flips the gallery between the light and dark themes.
class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.onPressed});

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

/// Small capsule carrying the product name.
class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.auto_awesome_rounded, size: 14, color: scheme.primary),
          const SizedBox(width: 7),
          Text(
            PreviewHubStrings.badgeLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
