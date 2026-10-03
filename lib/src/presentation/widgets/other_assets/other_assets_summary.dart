import 'package:flutter/material.dart';

import '../../../domain/models/asset_metrics.dart';
import '../../../util/preview_hub_strings.dart';

/// Line above the Other screen's list: how many files there are and what
/// they weigh together.
class OtherAssetsSummary extends StatelessWidget {
  /// Creates the summary of [fileCount] files weighing [totalBytes].
  const OtherAssetsSummary({
    required this.fileCount,
    required this.totalBytes,
    super.key,
  });

  /// Number of files listed.
  final int fileCount;

  /// Combined size of those files, in bytes.
  final int totalBytes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Text(
        PreviewHubStrings.otherSummary(
          fileCount,
          AssetMetrics.formatBytes(totalBytes),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
