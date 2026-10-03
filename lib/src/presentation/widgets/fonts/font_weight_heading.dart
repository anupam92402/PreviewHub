import 'package:flutter/material.dart';

import '../../../domain/models/asset_metrics.dart';
import '../../../domain/models/font_family_info.dart';
import '../../../util/preview_hub_strings.dart';

/// Heading of a font weight section, such as `Weight 400 · 84 KB`, with a rule
/// running to the edge.
class FontWeightHeading extends StatelessWidget {
  /// Creates the heading for [face], whose file is [sizeInBytes] long.
  const FontWeightHeading({
    required this.face,
    required this.sizeInBytes,
    super.key,
  });

  /// Face the heading names.
  final FontFace face;

  /// Size of the file behind [face], or null while it is unknown.
  final int? sizeInBytes;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String heading = PreviewHubStrings.fontWeightHeading(
      face.weight,
      italic: face.isItalic,
    );

    return Row(
      children: <Widget>[
        Text(
          heading,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
        if (sizeInBytes != null) ...<Widget>[
          const SizedBox(width: 8),
          Text(
            AssetMetrics.formatBytes(sizeInBytes),
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(width: 10),
        Expanded(
          child: Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
