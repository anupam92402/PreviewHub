import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/rive_asset.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../preview_hub_strings.dart';
import 'rive_player.dart';

/// One animation in the grid: it plays, and it can be held.
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

  /// Artboard the file opened with; a Rive file has no single running time.
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
    builder: (BuildContext context, bool failed, Widget? child) => _TileCard(
      asset: widget.asset,
      metrics: widget.metrics,
      onTap: widget.onTap,
      failed: failed,
      isPlaying: _isPlaying,
      label: _label,
      onFailed: () => _failed.value = true,
      onLoaded: (rive.RiveWidgetController c) => _label.value = c.artboard.name,
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

  final RiveAsset asset;
  final AssetMetricsService metrics;
  final VoidCallback onTap;
  final bool failed;
  final ValueNotifier<bool> isPlaying;
  final ValueNotifier<String?> label;
  final VoidCallback onFailed;
  final ValueChanged<rive.RiveWidgetController> onLoaded;

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
                              ? RivePlayerFailure(accent: accent)
                              : ValueListenableBuilder<bool>(
                                  valueListenable: isPlaying,
                                  builder:
                                      (
                                        BuildContext context,
                                        bool playing,
                                        Widget? child,
                                      ) => RivePlayer(
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

  final RiveAsset asset;
  final AssetMetricsService metrics;
  final ValueNotifier<String?> label;
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
          ValueListenableBuilder<String?>(
            valueListenable: label,
            builder: (BuildContext context, String? artboard, Widget? child) =>
                _FactsLine(
                  asset: asset,
                  metrics: metrics,
                  label: artboard,
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

  final RiveAsset asset;
  final AssetMetricsService metrics;
  final String? label;
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
              if (label != null && label!.isNotEmpty) label!,
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
