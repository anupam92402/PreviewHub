import 'package:flutter/material.dart';

import '../../../domain/models/font_family_info.dart';
import 'font_weight_heading.dart';
import 'font_weight_sample_row.dart';

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
        FontWeightHeading(face: face, sizeInBytes: sizeInBytes),
        const SizedBox(height: 10),
        for (final double size in sizeRamp)
          FontWeightSampleRow(family: family, face: face, size: size),
      ],
    ),
  );
}
