import 'package:flutter/material.dart';

import '../../../../domain/models/font_family_info.dart';
import 'font_compare_line.dart';

/// Both families at one size and weight, under a heading naming the size
/// with a rule running to the edge.
class FontComparePair extends StatelessWidget {
  /// Creates the pair setting [text] in [first] and [second] at [size].
  const FontComparePair({
    required this.size,
    required this.text,
    required this.first,
    required this.second,
    required this.weight,
    required this.showMetrics,
    super.key,
  });

  /// Font size, in points.
  final double size;

  /// Words both families are set in.
  final String text;

  /// Family on the first line.
  final FontFamilyInfo first;

  /// Family on the second line.
  final FontFamilyInfo second;

  /// Weight both families are set in.
  final FontWeight weight;

  /// Whether both lines draw their baseline.
  final bool showMetrics;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '${size.toInt()}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final FontFamilyInfo family in <FontFamilyInfo>[first, second])
            FontCompareLine(
              family: family,
              text: text,
              size: size,
              weight: weight,
              showMetrics: showMetrics,
            ),
        ],
      ),
    );
  }
}
