import 'package:flutter/material.dart';

import '../../../domain/models/preview_hub_config.dart';
import '../../../util/preview_hub_strings.dart';
import 'dashboard_header_badge.dart';
import 'dashboard_header_glow.dart';
import 'dashboard_size_breakdown_button.dart';
import 'dashboard_theme_toggle.dart';

/// Gradient hero at the top of the landing screen.
class DashboardHeader extends StatelessWidget {
  /// Creates the header for [config], flipping the theme with [onThemeToggle].
  const DashboardHeader({
    required this.config,
    required this.onThemeToggle,
    super.key,
  });

  /// Handed to the size breakdown, so the collections it opens list the same
  /// remote entries as everywhere else.
  final PreviewHubConfig config;

  /// Called when the theme toggle is tapped.
  final VoidCallback onThemeToggle;

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
            child: DashboardHeaderGlow(color: scheme.primary),
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
                    const DashboardHeaderBadge(),
                    const Spacer(),
                    DashboardSizeBreakdownButton(config: config),
                    const SizedBox(width: 8),
                    DashboardThemeToggle(onPressed: onThemeToggle),
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
