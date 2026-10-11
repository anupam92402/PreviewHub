import 'package:flutter/material.dart';

import '../../../../domain/models/font_family_info.dart';
import '../font_metrics_text.dart';

/// One side of a comparison at one size: the family's name, then the words set
/// at the chosen weight.
class FontCompareLine extends StatelessWidget {
  /// Creates the line setting [text] in [family] at [size] points.
  const FontCompareLine({
    required this.family,
    required this.text,
    required this.size,
    required this.weight,
    required this.showMetrics,
    super.key,
  });

  /// Family the words are set in.
  final FontFamilyInfo family;

  /// Words to set.
  final String text;

  /// Font size, in points.
  final double size;

  /// Weight the words are set in.
  final FontWeight weight;

  /// Whether the line draws its baseline.
  final bool showMetrics;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(
              family.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: FontMetricsText(
              text: text,
              showMetrics: showMetrics,
              style: TextStyle(
                fontFamily: family.manifestKey,
                fontSize: size,
                fontWeight: weight,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
