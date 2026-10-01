import 'package:flutter/material.dart';

import '../../domain/models/asset_size_report.dart';
import '../../preview_hub_strings.dart';
import '../theme/asset_size_style.dart';

/// A dot, a name and a share under the chart.
class AssetSizeLegendItem extends StatelessWidget {
  /// Creates the entry for [category].
  const AssetSizeLegendItem({
    required this.category,
    required this.share,
    required this.dimmed,
    required this.onTap,
    super.key,
  });

  /// Category named.
  final AssetSizeCategory category;

  /// Its share of the whole, from 0 to 1.
  final double share;

  /// Whether another category is picked out, which fades this one.
  final bool dimmed;

  /// Called when the entry is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: dimmed ? 0.45 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AssetSizeStyle.colorOf(category),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${category.label} ${PreviewHubStrings.sizePercent(share)}',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
