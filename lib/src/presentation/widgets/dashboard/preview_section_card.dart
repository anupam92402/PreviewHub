import 'package:flutter/material.dart';

import '../../../preview_section.dart';
import 'preview_section_card_badge.dart';
import 'preview_section_card_chevron.dart';

/// Tappable card for a single [PreviewSection].
class PreviewSectionCard extends StatelessWidget {
  /// Creates a card for [section].
  const PreviewSectionCard({
    required this.section,
    required this.onTap,
    super.key,
  });

  /// Section rendered by this card.
  final PreviewSection section;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final PreviewSectionStyle style = PreviewSectionStyle.of(section.type);
    final BorderRadius radius = BorderRadius.circular(22);

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: style.accentStart.withValues(alpha: 0.12),
        highlightColor: style.accentStart.withValues(alpha: 0.06),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              PreviewSectionCardBadge(style: style),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      section.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      section.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PreviewSectionCardChevron(style: style),
            ],
          ),
        ),
      ),
    );
  }
}
