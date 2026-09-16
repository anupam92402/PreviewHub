import 'package:flutter/material.dart';

import '../../domain/models/widget_preview.dart';
import '../../preview_hub_strings.dart';

/// Heading above a run of entries, carrying the count and the fold control.
class WidgetGroupHeader extends StatelessWidget {
  /// Creates a heading for the group named [name].
  const WidgetGroupHeader({
    required this.name,
    required this.count,
    required this.collapsed,
    required this.onTap,
    this.section,
    super.key,
  });

  /// Text of the heading.
  final String name;

  /// How many entries sit under it.
  final int count;

  /// Whether the entries are currently folded away.
  final bool collapsed;

  /// Called when the heading is tapped.
  final VoidCallback onTap;

  /// Kind of entry beneath the heading, shown as a tag beside the name. Null
  /// while the chips have already narrowed to one kind, where repeating it on
  /// every heading says nothing.
  final WidgetSection? section;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      if (section != null) ...<Widget>[
                        const SizedBox(width: 8),
                        _SectionTag(section: section!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    PreviewHubStrings.widgetCaseCount(count),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: collapsed ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                Icons.keyboard_arrow_up_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Boxed tag naming a group's kind, so the two halves stay apart by eye while
/// the index is showing both at once.
class _SectionTag extends StatelessWidget {
  const _SectionTag({required this.section});

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
