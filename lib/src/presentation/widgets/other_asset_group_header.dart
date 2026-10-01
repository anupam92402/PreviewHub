import 'package:flutter/material.dart';

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/other_asset.dart';
import '../../preview_hub_strings.dart';
import '../theme/other_asset_style.dart';

/// Heading above one kind of file: its name, how many there are, and what
/// they weigh together.
class OtherAssetGroupHeader extends StatelessWidget {
  /// Creates the heading for [group].
  const OtherAssetGroupHeader({required this.group, super.key});

  /// Group being headed.
  final OtherAssetGroup group;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color accent = OtherAssetStyle.colorOf(group.kind);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
      child: Row(
        children: <Widget>[
          Icon(OtherAssetStyle.iconOf(group.kind), size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              group.kind.label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            PreviewHubStrings.otherGroupSummary(
              group.assets.length,
              AssetMetrics.formatBytes(group.totalBytes),
            ),
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
