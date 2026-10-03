import 'package:flutter/material.dart';

import '../../../domain/models/asset_metrics.dart';
import '../../../domain/models/asset_size_report.dart';
import '../../../util/preview_hub_strings.dart';
import 'asset_size_donut.dart';
import 'asset_size_legend_item.dart';

/// The donut with the total in its hole, and the legend beneath.
class AssetSizeSummary extends StatelessWidget {
  /// Creates the card over [report].
  const AssetSizeSummary({
    required this.report,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// What is being charted.
  final AssetSizeReport report;

  /// Category picked out, or null.
  final AssetSizeCategory? selected;

  /// Called with the category tapped on the ring or in the legend.
  final ValueChanged<AssetSizeCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<AssetSizeCategory> categories = report.presentCategories;
    final AssetSizeCategory? selected = this.selected;

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
        child: Column(
          children: <Widget>[
            Semantics(
              label: PreviewHubStrings.sizeChartLabel(<String>[
                for (final AssetSizeCategory category in categories)
                  PreviewHubStrings.categoryShare(
                    category.label,
                    PreviewHubStrings.sizePercent(report.shareOf(category)),
                  ),
              ]),
              child: AssetSizeDonut(
                report: report,
                selected: selected,
                onSelect: onSelect,
                centre: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      AssetMetrics.formatBytes(
                        selected == null
                            ? report.totalBytes
                            : report.bytesOf(selected),
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected == null
                          ? PreviewHubStrings.sizeFiles(report.totalFiles)
                          : PreviewHubStrings.facts(<String>[
                              selected.label,
                              PreviewHubStrings.sizePercent(
                                report.shareOf(selected),
                              ),
                            ]),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                for (final AssetSizeCategory category in categories)
                  AssetSizeLegendItem(
                    category: category,
                    share: report.shareOf(category),
                    dimmed: selected != null && selected != category,
                    onTap: () => onSelect(category),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
