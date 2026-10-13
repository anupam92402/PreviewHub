import 'package:flutter/material.dart';

import '../../../domain/models/preview_hub_config.dart';
import '../../../domain/models/preview_hub_route_arguments.dart';
import '../../../routing/preview_hub_router.dart';
import '../../../routing/preview_hub_routes.dart';
import '../../../theme/preview_hub_theming.dart';
import '../../../util/preview_hub_strings.dart';

/// Opens the breakdown of what each kind of bundled asset weighs. Pushes the
/// route itself: the screen needs nothing from the dashboard beyond the
/// gallery's theme, which the button can already reach.
class DashboardSizeBreakdownButton extends StatelessWidget {
  /// Creates the button, handing [config] to the breakdown it opens.
  const DashboardSizeBreakdownButton({required this.config, super.key});

  /// Passed to the breakdown, so the collections it opens list the same
  /// remote entries as everywhere else.
  final PreviewHubConfig config;

  /// Pushes the size breakdown under the gallery's current theme.
  void _open(BuildContext context) => Navigator.of(context).push(
    PreviewHubRouter.route(
      PreviewHubRoutes.assetSizes,
      arguments: AssetSizesArguments(
        config: config,
        themeController: PreviewHubTheming.controllerOf(context),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return IconButton.filledTonal(
      tooltip: PreviewHubStrings.sizeTooltip,
      onPressed: () => _open(context),
      iconSize: 18,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: scheme.surface.withValues(alpha: 0.7),
        foregroundColor: scheme.onSurfaceVariant,
      ),
      icon: const Icon(Icons.bar_chart_outlined),
    );
  }
}
