import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import '../../../domain/models/rive_asset.dart';
import '../../../domain/services/asset_metrics_service.dart';
import '../../../util/preview_hub_strings.dart';
import '../common/animation_playback_failure.dart';
import '../common/animation_tile/animation_tile_card.dart';
import 'rive_player.dart';

/// One animation in the Rive grid: it plays, and it can be held.
class RiveTile extends StatefulWidget {
  /// Creates a tile for [asset].
  const RiveTile({
    required this.asset,
    required this.metrics,
    required this.onTap,
    super.key,
  });

  /// Animation shown by this tile.
  final RiveAsset asset;

  /// Shared measurement cache, watched for this asset only.
  final AssetMetricsService metrics;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  State<RiveTile> createState() => _RiveTileState();
}

class _RiveTileState extends State<RiveTile> {
  final ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _failed = ValueNotifier<bool>(false);

  /// Artboard the file opened with, shown once it has loaded.
  final ValueNotifier<String?> _label = ValueNotifier<String?>(null);

  /// Clears per-asset state, since the grid recycles tiles by position and a
  /// stale failure or label would stick to the next animation.
  @override
  void didUpdateWidget(RiveTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.asset != oldWidget.asset) {
      _failed.value = false;
      _label.value = null;
      _isPlaying.value = true;
    }
  }

  @override
  void dispose() {
    _isPlaying.dispose();
    _failed.dispose();
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: _failed,
    builder: (BuildContext context, bool failed, Widget? child) =>
        AnimationTileCard(
          asset: widget.asset,
          name: widget.asset.name,
          metrics: widget.metrics,
          onTap: widget.onTap,
          failed: failed,
          isPlaying: _isPlaying,
          label: _label,
          failure: AnimationPlaybackFailure(
            message: PreviewHubStrings.riveFailed,

            accent: Theme.of(context).colorScheme.error,
          ),
          player: ValueListenableBuilder<bool>(
            valueListenable: _isPlaying,
            builder: (BuildContext context, bool playing, Widget? child) =>
                RivePlayer(
                  asset: widget.asset,
                  isPlaying: playing,
                  onLoaded: (rive.RiveWidgetController controller) =>
                      _label.value = controller.artboard.name,
                  onFailed: () => _failed.value = true,
                ),
          ),
        ),
  );
}
