import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';

/// One label and value line on a detail screen, with an optional copy button.
class DetailRow extends StatelessWidget {
  /// Shows [value] beside [label].
  const DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.onCopy,
    super.key,
  });

  /// Name of the fact, in the left column.
  final String label;

  /// The fact itself; selectable so it can be copied by hand.
  final String value;

  /// Colour that emphasises the value, drawn bold, or null for plain text.
  final Color? valueColor;

  /// Called by the trailing copy button, or null for no button.
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.35,
                color: valueColor,
                fontWeight: valueColor == null ? null : FontWeight.w700,
              ),
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              tooltip: PreviewHubStrings.copy,
              iconSize: 17,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
    );
  }
}
