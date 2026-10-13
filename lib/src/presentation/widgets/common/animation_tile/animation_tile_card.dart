import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/measurable_asset.dart';
import '../../../../domain/services/asset_metrics_service.dart';
import '../../../../util/preview_hub_strings.dart';
import '../source_badge.dart';
import 'animation_tile_footer.dart';
import 'tile_play_toggle.dart';

/// The grid card shared by the Lottie and Rive collections: the playing
/// animation with its source badge and play toggle, above its name and facts.
class AnimationTileCard extends StatelessWidget {
  /// Creates the card for [asset], showing [player] or, once it gives up,
  /// [failure].
  const AnimationTileCard({
    required this.asset,
    required this.name,
    required this.metrics,
    required this.onTap,
    required this.failed,
    required this.isPlaying,
    required this.label,
    required this.player,
    required this.failure,
    super.key,
  });

  /// Animation shown by this card.
  final MeasurableAsset asset;

  /// File name shown under the animation.
  final String name;

  /// Shared measurement cache, watched for this asset only.
  final AssetMetricsService metrics;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// Whether the animation could not be played.
  final bool failed;

  /// Whether the animation is running; the play toggle flips it.
  final ValueNotifier<bool> isPlaying;

  /// Short fact the file reports about itself once loaded, such as its running
  /// time or artboard.
  final ValueListenable<String?> label;

  /// The playing animation.
  final Widget player;

  /// Stands in for [player] when the file cannot be played.
  final Widget failure;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = failed ? scheme.error : scheme.primary;
    final BorderRadius radius = BorderRadius.circular(16);

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: ColoredBox(
                        color: accent.withValues(alpha: failed ? 0.10 : 0.06),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: failed ? failure : player,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: SourceBadge(
                        source: asset.source,
                        accent: accent,
                        tooltip: PreviewHubStrings.animationSource(
                          asset.source.label,
                        ),
                      ),
                    ),
                    if (!failed)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: TilePlayToggle(
                          isPlaying: isPlaying,
                          accent: accent,
                        ),
                      ),
                  ],
                ),
              ),
              AnimationTileFooter(
                asset: asset,
                name: name,
                metrics: metrics,
                label: label,
                failed: failed,
                accent: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
