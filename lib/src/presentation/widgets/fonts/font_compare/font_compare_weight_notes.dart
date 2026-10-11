import 'package:flutter/material.dart';

import '../../../../domain/models/font_family_info.dart';
import '../../../../util/preview_hub_strings.dart';

/// Says, for each compared family with no file at the chosen weight, which
/// nearby weight is drawn instead. Draws nothing when both have the weight.
class FontCompareWeightNotes extends StatelessWidget {
  /// Creates the notes for [families] set at [weight].
  const FontCompareWeightNotes({
    required this.families,
    required this.weight,
    super.key,
  });

  /// Families being compared; a family on both sides is noted once.
  final List<FontFamilyInfo> families;

  /// Weight both families are set in.
  final int weight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<String> notes = <String>[
      for (final FontFamilyInfo family in families.toSet())
        if (family.nearestWeight(weight) case final int nearest
            when nearest != weight)
          PreviewHubStrings.fontNearestWeight(family.name, weight, nearest),
    ];
    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: <Widget>[
          for (final String note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: scheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
