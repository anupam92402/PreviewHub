import 'package:flutter/material.dart';

import '../../../domain/models/font_family_info.dart';
import '../../../util/preview_hub_strings.dart';

/// Names the standard weights a family has no upright file for. Draws nothing
/// for a family that ships all nine.
class FontMissingWeights extends StatelessWidget {
  /// Creates the note for [family].
  const FontMissingWeights({required this.family, super.key});

  /// Family whose weights are checked.
  final FontFamilyInfo family;

  @override
  Widget build(BuildContext context) {
    final List<int> missing = family.missingWeights;
    if (missing.isEmpty) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, size: 16, color: scheme.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              PreviewHubStrings.fontMissingWeights(missing),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
