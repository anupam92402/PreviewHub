import 'package:flutter/material.dart';

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/asset_size_report.dart';
import '../../preview_hub_strings.dart';
import 'asset_size_meter.dart';

/// One file: its name and path, its size, and a bar against the heaviest file
/// in its category. Tapping it opens the file's preview.
class AssetSizeFileRow extends StatelessWidget {
  /// Creates the row for [entry], measured against [largest].
  const AssetSizeFileRow({
    required this.entry,
    required this.largest,
    required this.color,
    required this.onTap,
    super.key,
  });

  /// File shown.
  final AssetSizeEntry entry;

  /// Bytes of the heaviest file in the same category, which fills the bar.
  final int largest;

  /// Colour of the category, used for the bar.
  final Color color;

  /// Called when the row is tapped, to open the file's preview.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (entry.fileCount > 1) ...<Widget>[
                  Text(
                    PreviewHubStrings.sizeVariants(entry.fileCount),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  AssetMetrics.formatBytes(entry.bytes),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
            Text(
              entry.locator,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 5),
            AssetSizeMeter(
              value: largest == 0 ? 0 : entry.bytes / largest,
              color: color.withValues(alpha: 0.7),
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}
