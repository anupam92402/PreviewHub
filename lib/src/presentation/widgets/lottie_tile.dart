import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/lottie_asset.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../preview_hub_strings.dart';
import 'lottie_player.dart';

/// One animation in the grid: it plays, and it can be held.
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
  // A composition carries no name of its own, so the label is what it can
  // actually tell us: how long it runs.
  final ValueNotifier<Duration?> _label = ValueNotifier<Duration?>(null);

  @override
  void didUpdateWidget(LottieTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The grid recycles tiles by position, so a failure or a label left from
    // the previous animation would stick to a perfectly good one.
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
    builder: (BuildContext context, bool failed, Widget? child) => _TileCard(
      asset: widget.asset,
      metrics: widget.metrics,
      onTap: widget.onTap,
      failed: failed,
      isPlaying: _isPlaying,
      label: _label,
      onFailed: () => _failed.value = true,
      onLoaded: (LottieComposition c) => _label.value = c.duration,
    ),
  );
}

/// The card itself, told whether its animation gave up.
class _TileCard extends StatelessWidget {
  const _TileCard({
    required this.asset,
    required this.metrics,
    required this.onTap,
    required this.failed,
    required this.isPlaying,
    required this.label,
    required this.onFailed,
    required this.onLoaded,
  });

  final LottieAsset asset;
  final AssetMetricsService metrics;
  final VoidCallback onTap;
  final bool failed;
  final ValueNotifier<bool> isPlaying;
  final ValueNotifier<Duration?> label;
  final VoidCallback onFailed;
  final ValueChanged<LottieComposition> onLoaded;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
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
                          child: failed
                              ? LottiePlayerFailure(accent: accent)
                              : ValueListenableBuilder<bool>(
                                  valueListenable: isPlaying,
                                  builder:
                                      (
                                        BuildContext context,
                                        bool playing,
                                        Widget? child,
                                      ) => LottiePlayer(
                                        asset: asset,
                                        isPlaying: playing,
                                        onLoaded: onLoaded,
                                        onFailed: onFailed,
                                      ),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _SourceBadge(source: asset.source, accent: accent),
                    ),
                    if (!failed)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: _PlayToggle(
                          isPlaying: isPlaying,
                          accent: accent,
                        ),
                      ),
                  ],
                ),
              ),
              _TileFooter(
                asset: asset,
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

/// Holds and resumes the animation without leaving the grid.
class _PlayToggle extends StatelessWidget {
  const _PlayToggle({required this.isPlaying, required this.accent});

  final ValueNotifier<bool> isPlaying;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: isPlaying,
      builder: (BuildContext context, bool playing, Widget? child) => Material(
        color: scheme.surface.withValues(alpha: 0.85),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: playing
              ? PreviewHubStrings.lottiePause
              : PreviewHubStrings.lottiePlay,
          iconSize: 15,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          padding: EdgeInsets.zero,
          onPressed: () => isPlaying.value = !playing,
          icon: Icon(
            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: accent,
          ),
        ),
      ),
    );
  }
}

/// Says at a glance whether an animation was bundled or fetched.
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, required this.accent});

  final AssetSource source;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: '${source.label} animation',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(
          switch (source) {
            AssetSource.bundled => Icons.folder_outlined,
            AssetSource.network => Icons.cloud_outlined,
          },
          size: 13,
          color: accent,
        ),
      ),
    );
  }
}

/// Name, the composition's own label, and the file size.
class _TileFooter extends StatelessWidget {
  const _TileFooter({
    required this.asset,
    required this.metrics,
    required this.label,
    required this.failed,
    required this.accent,
  });

  final LottieAsset asset;
  final AssetMetricsService metrics;
  final ValueNotifier<Duration?> label;
  final bool failed;
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
                  asset.name,
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
          ValueListenableBuilder<Duration?>(
            valueListenable: label,
            builder:
                (BuildContext context, Duration? duration, Widget? child) =>
                    _FactsLine(
                      asset: asset,
                      metrics: metrics,
                      label: duration,
                      failed: failed,
                      accent: accent,
                    ),
          ),
        ],
      ),
    );
  }
}

/// The composition's label and the file size, as they arrive.
class _FactsLine extends StatelessWidget {
  const _FactsLine({
    required this.asset,
    required this.metrics,
    required this.label,
    required this.failed,
    required this.accent,
  });

  final LottieAsset asset;
  final AssetMetricsService metrics;
  final Duration? label;
  final bool failed;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

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
              if (label != null) PreviewHubStrings.lottieDuration(label!),
              switch (state.status) {
                MetricsStatus.loading => '…',
                MetricsStatus.failed => PreviewHubStrings.unknown,
                MetricsStatus.ready => AssetMetrics.formatBytes(
                  state.metrics.sizeInBytes,
                ),
              },
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
          ),
    );
  }
}
