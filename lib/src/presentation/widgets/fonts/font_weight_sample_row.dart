import 'package:flutter/material.dart';

import '../../../domain/models/font_family_info.dart';
import '../../../util/preview_hub_strings.dart';
import 'font_metrics_text.dart';

/// The sample words at one step of a font weight section's size ramp, with
/// the size in points beside them.
class FontWeightSampleRow extends StatelessWidget {
  /// Creates the row setting [face] of [family] at [size] points.
  const FontWeightSampleRow({
    required this.family,
    required this.face,
    required this.size,
    required this.showMetrics,
    super.key,
  });

  /// Family the face belongs to.
  final FontFamilyInfo family;

  /// Face the sample is set in.
  final FontFace face;

  /// Font size of the sample, in points.
  final double size;

  /// Whether the line draws its baseline.
  final bool showMetrics;

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
            child: FontMetricsText(
              text: PreviewHubStrings.fontSampleText,
              showMetrics: showMetrics,
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
