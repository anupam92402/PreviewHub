import 'package:flutter/material.dart';

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/asset_size_report.dart';
import '../../preview_hub_strings.dart';
import '../theme/asset_size_style.dart';
import 'asset_size_file_row.dart';
import 'asset_size_meter.dart';

/// One category: its share of the whole, and when open, its heaviest files,
/// each opening its own preview, and a way into the whole collection.
///
/// The tile only reports what was tapped; the screen holding it decides where
/// that leads, since it owns the configuration and measurement caches the
/// destination screens need.
class AssetSizeCategoryTile extends StatelessWidget {
  /// Creates the tile for [category] in [report].
  const AssetSizeCategoryTile({
    required this.report,
    required this.category,
    required this.expanded,
    required this.onTap,
    required this.onOpenFile,
    required this.onOpenCollection,
    super.key,
  });

  /// Most files listed under an open category.
  static const int _fileLimit = 8;

  /// The breakdown the category belongs to.
  final AssetSizeReport report;

  /// Category shown.
  final AssetSizeCategory category;

  /// Whether its heaviest files are listed.
  final bool expanded;

  /// Called when the tile is tapped, to open or fold it.
  final VoidCallback onTap;

  /// Called with the file whose row was tapped, to preview it.
  final ValueChanged<AssetSizeEntry> onOpenFile;

  /// Called when the button opening the whole collection is tapped.
  final VoidCallback onOpenCollection;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color accent = AssetSizeStyle.colorOf(category);
    final List<AssetSizeEntry> files = report.entriesOf(category);
    final double share = report.shareOf(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: expanded
            ? accent.withValues(alpha: 0.08)
            : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: expanded
                ? accent.withValues(alpha: 0.45)
                : scheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        AssetSizeStyle.iconOf(category),
                        size: 19,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            category.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            PreviewHubStrings.sizeAssets(files.length),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          AssetMetrics.formatBytes(report.bytesOf(category)),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          PreviewHubStrings.sizePercent(share),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AssetSizeMeter(value: share, color: accent),
                if (expanded) ...<Widget>[
                  const SizedBox(height: 14),
                  for (final AssetSizeEntry file in files.take(_fileLimit))
                    AssetSizeFileRow(
                      entry: file,
                      largest: files.first.bytes,
                      color: accent,
                      onTap: () => onOpenFile(file),
                    ),
                  if (files.length > _fileLimit)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        PreviewHubStrings.sizeMore(files.length - _fileLimit),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilledButton.tonalIcon(
                      onPressed: onOpenCollection,
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: accent,
                        backgroundColor: accent.withValues(alpha: 0.14),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(
                        PreviewHubStrings.sizeOpenCollection(category.label),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
