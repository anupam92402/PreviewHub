import 'package:flutter/material.dart';

import '../../../domain/models/widget_preview.dart';

/// Boxed tag naming a widget group's kind, so the two halves stay apart by eye
/// while the index is showing both at once.
class WidgetSectionTag extends StatelessWidget {
  /// Creates the tag for [section].
  const WidgetSectionTag({required this.section, super.key});

  /// Kind of entry the tag names.
  final WidgetSection section;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = switch (section) {
      WidgetSection.components => scheme.primary,
      WidgetSection.screens => scheme.tertiary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
        color: accent.withValues(alpha: 0.10),
      ),
      child: Text(
        section.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: accent,
        ),
      ),
    );
  }
}
