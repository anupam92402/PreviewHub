import 'package:flutter/material.dart';

import '../../../../domain/models/asset_metrics.dart';
import '../../../../domain/models/measurable_asset.dart';
import '../../../../domain/services/asset_metrics_service.dart';
import '../../../../util/preview_hub_strings.dart';

/// The label an animation reports and its file size, filled in as each
/// arrives, or the unavailable notice when it cannot be played.
class AnimationFactsLine extends StatelessWidget {
  /// Creates the line for [asset].
  const AnimationFactsLine({
    required this.asset,
    required this.metrics,
    required this.label,
    required this.failed,
    required this.accent,
    super.key,
  });

  /// Animation described by this line.
  final MeasurableAsset asset;

  /// Shared measurement cache, watched for this asset only.
  final AssetMetricsService metrics;

  /// Short fact the file reports about itself, or null until it loads.
  final String? label;

  /// Whether the animation could not be played.
  final bool failed;

  /// Colour of the unavailable notice.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String? fact = label;

    if (failed) {
      return Text(
        PreviewHubStrings.assetUnavailable,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 10, color: accent),
      );
    }

    return ValueListenableBuilder<AssetMetricsState>(
      valueListenable: metrics.watch(asset),
      builder: (BuildContext context, AssetMetricsState state, Widget? child) =>
          Text(
            <String>[
              if (fact != null && fact.isNotEmpty) fact,
              switch (state.status) {
                MetricsStatus.loading => PreviewHubStrings.pending,
                MetricsStatus.failed => PreviewHubStrings.unknown,
                MetricsStatus.ready => AssetMetrics.formatBytes(
                  state.metrics.sizeInBytes,
                ),
              },
            ].join(PreviewHubStrings.factSeparator),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
          ),
    );
  }
}
