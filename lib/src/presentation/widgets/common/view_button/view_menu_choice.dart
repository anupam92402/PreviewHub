import 'package:flutter/material.dart';

/// One line in the view menu: a glyph and a label, drawn in [accent] and bold
/// while [selected].
class ViewMenuChoice extends StatelessWidget {
  /// Creates the line reading [label] beside [icon].
  const ViewMenuChoice({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
    super.key,
  });

  /// Glyph before the label.
  final IconData icon;

  /// Name of the choice.
  final String label;

  /// Whether this choice is the one in use.
  final bool selected;

  /// Colour of the glyph and label while selected.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 18,
          color: selected ? accent : scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? accent : null,
            ),
          ),
        ),
      ],
    );
  }
}
