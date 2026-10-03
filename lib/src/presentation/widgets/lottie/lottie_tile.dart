import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../domain/models/lottie_asset.dart';
import '../../../domain/services/asset_metrics_service.dart';
import '../../../util/preview_hub_strings.dart';
import '../common/animation_playback_failure.dart';
import '../common/animation_tile/animation_tile_card.dart';
import 'lottie_player.dart';

/// One animation in the Lottie grid: it plays, and it can be held.
class LottieTile extends StatefulWidget {
  /// Creates a tile for [asset].
  const LottieTile({
    required this.asset,
    required this.metrics,
    required this.onTap,
    super.key,
  });

  /// Animation shown by this tile.
  final LottieAsset asset;

  /// Shared measurement cache, watched for this asset only.
  final AssetMetricsService metrics;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  State<LottieTile> createState() => _LottieTileState();
}

class _LottieTileState extends State<LottieTile> {
  final ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _failed = ValueNotifier<bool>(false);

  /// Running time, shown once the composition has loaded.
  final ValueNotifier<String?> _label = ValueNotifier<String?>(null);

  /// Clears per-asset state, since the grid recycles tiles by position and a
  /// stale failure or label would stick to the next animation.
  @override
  void didUpdateWidget(LottieTile oldWidget) {
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
            message: PreviewHubStrings.lottieFailed,

            accent: Theme.of(context).colorScheme.error,
          ),
          player: ValueListenableBuilder<bool>(
            valueListenable: _isPlaying,
            builder: (BuildContext context, bool playing, Widget? child) =>
                LottiePlayer(
                  asset: widget.asset,
                  isPlaying: playing,
                  onLoaded: (LottieComposition composition) => _label.value =
                      PreviewHubStrings.lottieDuration(composition.duration),
                  onFailed: () => _failed.value = true,
                ),
          ),
        ),
  );
}
