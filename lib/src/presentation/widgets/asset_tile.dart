import 'package:flutter/material.dart';

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../preview_hub_strings.dart';
import '../theme/asset_type_style.dart';
import 'asset_preview.dart';

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
      builder: (BuildContext context, bool failed, Widget? child) => _TileCard(
        asset: widget.asset,
        metrics: widget.metrics,
        onTap: widget.onTap,
        failed: failed,
        onFailed: () => _failed.value = true,
      ),
    );
  }
}

/// The card itself, told whether its artwork gave up.
class _TileCard extends StatelessWidget {
  const _TileCard({
    required this.asset,
    required this.metrics,
    required this.onTap,
    required this.failed,
    required this.onFailed,
  });

  /// Width the footer needs before the trailing glyph earns its space.
  static const double _iconMinWidth = 96;

  /// Asset shown by this card.
  final PreviewAsset asset;

  /// Shared measurement cache, watched for this asset only.
  final AssetMetricsService metrics;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// Whether the artwork could not be drawn.
  final bool failed;

  /// Called the first time the artwork fails.
  final VoidCallback onFailed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color accent = failed
        ? scheme.error
        : AssetTypeStyle.colorOf(asset.type);
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
                          padding: const EdgeInsets.all(14),
                          child: failed
                              ? AssetPreviewFailure(accent: accent)
                              : AssetPreview(
                                  asset: asset,
                                  onDimensions: (int width, int height) =>
                                      metrics.recordDimensions(
                                        asset,
                                        width,
                                        height,
                                      ),
                                  onFailed: onFailed,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _SourceBadge(source: asset.source, accent: accent),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) =>
                              Row(
                                children: <Widget>[
                                  _TypeBadge(
                                    label: asset.type.label,
                                    accent: AssetTypeStyle.colorOf(asset.type),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      asset.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  if (constraints.maxWidth >=
                                      _iconMinWidth) ...<Widget>[
                                    Icon(
                                      failed
                                          ? Icons.error_outline_rounded
                                          : Icons.info_outline_rounded,
                                      size: 15,
                                      color: failed
                                          ? accent
                                          : scheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                ],
                              ),
                    ),
                    const SizedBox(height: 2),
                    if (failed)
                      Text(
                        PreviewHubStrings.assetUnavailable,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: accent),
                      )
                    else
                      _FactsLine(asset: asset, metrics: metrics),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Format capsule, coloured so a type is recognisable without reading it.
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: accent,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        color: Colors.white,
      ),
    ),
  );
}

/// Says at a glance whether an asset was bundled or fetched.
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, required this.accent});

  final AssetSource source;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: '${source.label} asset',
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

/// Dimensions and weight, filled in as the measurements land.
class _FactsLine extends StatelessWidget {
  const _FactsLine({required this.asset, required this.metrics});

  final PreviewAsset asset;
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

  String _describe(AssetMetricsState state) {
    final String size = switch (state.status) {
      MetricsStatus.loading => '…',
      MetricsStatus.failed => 'unknown',
      MetricsStatus.ready => AssetMetrics.formatBytes(
        state.metrics.sizeInBytes,
      ),
    };
    return '${describeDimensions(asset, state.metrics)} · $size';
  }
}

/// `96 × 96` for raster assets, `Vector` for SVG, `…` while still decoding.
String describeDimensions(PreviewAsset asset, AssetMetrics metrics) {
  if (!asset.type.isRaster) {
    return 'Vector';
  }
  if (metrics.width == null || metrics.height == null) {
    return '…';
  }
  return '${metrics.width} × ${metrics.height}';
}
