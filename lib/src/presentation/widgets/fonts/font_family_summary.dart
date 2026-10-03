import 'package:flutter/material.dart';

import '../../../domain/models/asset_metrics.dart';
import '../../../domain/models/font_family_info.dart';
import '../../../util/preview_hub_strings.dart';

/// The open family's name, set in itself, with its face count and total file
/// size.
class FontFamilySummary extends StatelessWidget {
  /// Creates the summary of [family], whose files total [sizeInBytes].
  const FontFamilySummary({
    required this.family,
    required this.sizeInBytes,
    super.key,
  });

  /// Family being summarised.
  final FontFamilyInfo family;

  /// Combined size of the family's files, or null while it is unknown.
  final int? sizeInBytes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                family.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: family.manifestKey,
                  fontSize: 26,
                  fontWeight: family.representativeFace.fontWeight,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                PreviewHubStrings.fontFaceCount(family.faces.length),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (sizeInBytes != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AssetMetrics.formatBytes(sizeInBytes),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
