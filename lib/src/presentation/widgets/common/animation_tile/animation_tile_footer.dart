import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/measurable_asset.dart';
import '../../../../domain/services/asset_metrics_service.dart';
import 'animation_facts_line.dart';

/// The name of an animation in the grid, with its facts line underneath.
class AnimationTileFooter extends StatelessWidget {
  /// Creates the footer for [asset].
  const AnimationTileFooter({
    required this.asset,
    required this.name,
    required this.metrics,
    required this.label,
    required this.failed,
    required this.accent,
    super.key,
  });

  /// Animation named by this footer.
  final MeasurableAsset asset;

  /// File name shown under the animation.
  final String name;

  /// Shared measurement cache, watched for this asset only.
  final AssetMetricsService metrics;

  /// Short fact the file reports about itself once loaded.
  final ValueListenable<String?> label;

  /// Whether the animation could not be played.
  final bool failed;

  /// Colour of the failure glyph and text.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                failed
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                size: 15,
                color: failed ? accent : scheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 2),
          ValueListenableBuilder<String?>(
            valueListenable: label,
            builder: (BuildContext context, String? fact, Widget? child) =>
                AnimationFactsLine(
                  asset: asset,
                  metrics: metrics,
                  label: fact,
                  failed: failed,
                  accent: accent,
                ),
          ),
        ],
      ),
    );
  }
}
