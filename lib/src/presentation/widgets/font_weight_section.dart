import 'package:flutter/material.dart';

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/font_family_info.dart';
import '../../preview_hub_strings.dart';

/// One face of a family, shown down a ramp of sizes.
class FontWeightSection extends StatelessWidget {
  /// Creates a section for [face] of [family].
  const FontWeightSection({
    required this.family,
    required this.face,
    required this.sizeInBytes,
    super.key,
  });

  /// Sizes the ramp steps through, in points.
  static const List<double> sizeRamp = <double>[8, 12, 16, 20, 24, 28, 32];

  /// Family the face belongs to.
  final FontFamilyInfo family;

  /// Face being shown.
  final FontFace face;

  /// Size of the file behind [face], or null while it is unknown.
  final int? sizeInBytes;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _WeightHeading(face: face, sizeInBytes: sizeInBytes),
        const SizedBox(height: 10),
        for (final double size in sizeRamp)
          _SampleRow(family: family, face: face, size: size),
      ],
    ),
  );
}

/// `Weight 400 · 84 KB`, with a rule running to the edge.
class _WeightHeading extends StatelessWidget {
  const _WeightHeading({required this.face, required this.sizeInBytes});

  final FontFace face;
  final int? sizeInBytes;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String heading = face.isItalic
        ? '${PreviewHubStrings.fontWeightHeading(face.weight)} '
              '${PreviewHubStrings.fontItalicSuffix}'
        : PreviewHubStrings.fontWeightHeading(face.weight);

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

/// The sample words at one step of the ramp.
class _SampleRow extends StatelessWidget {
  const _SampleRow({
    required this.family,
    required this.face,
    required this.size,
  });

  final FontFamilyInfo family;
  final FontFace face;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 28,
            child: Text(
              '${size.toInt()}',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              PreviewHubStrings.fontSampleText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: family.manifestKey,
                fontSize: size,
                fontWeight: face.fontWeight,
                fontStyle: face.fontStyle,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
