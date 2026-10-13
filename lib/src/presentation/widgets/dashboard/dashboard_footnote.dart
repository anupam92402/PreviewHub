import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';

/// Closing nudge under the dashboard's section list.
class DashboardFootnote extends StatelessWidget {
  /// Creates the footnote.
  const DashboardFootnote({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.bolt_rounded,
          size: 18,
          color: scheme.primary.withValues(alpha: 0.85),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            PreviewHubStrings.footnote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
