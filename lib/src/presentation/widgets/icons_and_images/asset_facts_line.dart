import 'package:flutter/material.dart';

import '../../../domain/models/asset_metrics.dart';
import '../../../domain/models/preview_asset.dart';
import '../../../domain/services/asset_metrics_service.dart';
import '../../../util/preview_hub_strings.dart';

/// An asset tile's dimensions and weight, filled in as the measurements land.
class AssetFactsLine extends StatelessWidget {
  /// Creates the line describing [asset] from [metrics].
  const AssetFactsLine({required this.asset, required this.metrics, super.key});

  /// Asset described.
  final PreviewAsset asset;

  /// Shared measurement cache, watched for this asset only.
  final AssetMetricsService metrics;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<AssetMetricsState>(
      valueListenable: metrics.watch(asset),
      builder: (BuildContext context, AssetMetricsState state, Widget? child) =>
          Text(
            _describe(state),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
          ),
    );
  }

  /// Dimensions and byte size joined into one line.
  String _describe(AssetMetricsState state) {
    final String size = switch (state.status) {
      MetricsStatus.loading => PreviewHubStrings.pending,
      MetricsStatus.failed => PreviewHubStrings.unknown,
      MetricsStatus.ready => AssetMetrics.formatBytes(
        state.metrics.sizeInBytes,
      ),
    };
    return PreviewHubStrings.facts(<String>[
      PreviewHubStrings.imageDimensions(
        isVector: !asset.type.isRaster,
        width: state.metrics.width,
        height: state.metrics.height,
      ),
      size,
    ]);
  }
}
