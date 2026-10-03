import 'package:flutter/material.dart';

/// One line of the font sample checklist: a tick or an empty ring beside the
/// name of a choice.
class FontSampleChecklistRow extends StatelessWidget {
  /// Creates a row for the choice [label], ticked when [done].
  const FontSampleChecklistRow({
    required this.label,
    required this.done,
    super.key,
  });

  /// Name of the choice.
  final String label;

  /// Whether the choice has been made.
  final bool done;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color tone = done ? scheme.primary : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: tone,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}
