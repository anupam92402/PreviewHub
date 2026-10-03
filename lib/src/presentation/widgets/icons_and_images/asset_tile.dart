import 'package:flutter/material.dart';

import '../../../domain/models/preview_asset.dart';
import '../../../domain/services/asset_metrics_service.dart';
import 'asset_tile_card.dart';

/// One asset in the grid: artwork, format, origin and lazily measured facts.
/// Repaints itself in the error colour when the artwork cannot be drawn, so a
/// broken asset is obvious in a grid of fifty rather than needing to be read.
class AssetTile extends StatefulWidget {
  /// Creates a tile for [asset].
  const AssetTile({
    required this.asset,
    required this.metrics,
    required this.onTap,
    super.key,
  });

  /// Asset shown by this tile.
  final PreviewAsset asset;

  /// Shared measurement cache, watched for this asset only.
  final AssetMetricsService metrics;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  State<AssetTile> createState() => _AssetTileState();
}

class _AssetTileState extends State<AssetTile> {
  final ValueNotifier<bool> _failed = ValueNotifier<bool>(false);

  @override
  void didUpdateWidget(AssetTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.asset != oldWidget.asset) {
      _failed.value = false;
    }
  }

  @override
  void dispose() {
    _failed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _failed,
      builder: (BuildContext context, bool failed, Widget? child) =>
          AssetTileCard(
            asset: widget.asset,
            metrics: widget.metrics,
            onTap: widget.onTap,
            failed: failed,
            onFailed: () => _failed.value = true,
          ),
    );
  }
}
