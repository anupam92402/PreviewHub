import 'package:flutter/material.dart';

import '../../../domain/models/preview_asset.dart';
import '../../../domain/services/asset_metrics_service.dart';
import '../../../theme/asset_type_style.dart';
import '../../../util/preview_hub_strings.dart';
import '../common/source_badge.dart';
import 'asset_facts_line.dart';
import 'asset_preview.dart';
import 'asset_preview_failure.dart';
import 'asset_type_badge.dart';

/// The card drawn for an asset tile, told whether its artwork gave up.
class AssetTileCard extends StatelessWidget {
  /// Creates the card for [asset], in the error colour when [failed].
  const AssetTileCard({
    required this.asset,
    required this.metrics,
    required this.onTap,
    required this.failed,
    required this.onFailed,
    super.key,
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
                      child: SourceBadge(
                        source: asset.source,
                        accent: accent,
                        tooltip: PreviewHubStrings.assetSource(
                          asset.source.label,
                        ),
                      ),
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
                                  AssetTypeBadge(
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
                      AssetFactsLine(asset: asset, metrics: metrics),
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
