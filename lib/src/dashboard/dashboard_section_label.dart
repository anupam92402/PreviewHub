import 'package:flutter/material.dart';

/// Small caps heading with a rule running to the edge.
class DashboardSectionLabel extends StatelessWidget {
  /// Creates a heading reading [label].
  const DashboardSectionLabel({required this.label, super.key});

  /// Text of the heading.
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: scheme.outlineVariant.withValues(alpha: 0.6),
            height: 1,
          ),
        ),
      ],
    );
  }
}
