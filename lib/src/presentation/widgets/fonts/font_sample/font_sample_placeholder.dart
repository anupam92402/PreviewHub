import 'package:flutter/material.dart';

import '../../../../util/preview_hub_strings.dart';

/// Shown when every choice is made but nothing has been typed yet.
class FontSamplePlaceholder extends StatelessWidget {
  /// Creates the placeholder.
  const FontSamplePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.keyboard_alt_outlined,
            size: 30,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            PreviewHubStrings.fontSamplePlaceholder,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
