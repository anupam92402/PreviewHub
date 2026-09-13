import 'package:flutter/material.dart';

import '../preview_section.dart';

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
              _SectionBadge(style: style),
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
              _SectionChevron(style: style),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient tile carrying the section glyph.
class _SectionBadge extends StatelessWidget {
  const _SectionBadge({required this.style});

  final PreviewSectionStyle style;

  @override
  Widget build(BuildContext context) => Container(
    width: 54,
    height: 54,
    decoration: BoxDecoration(
      gradient: style.gradient,
      borderRadius: BorderRadius.circular(17),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: style.accentStart.withValues(alpha: 0.32),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Icon(style.icon, color: Colors.white, size: 26),
  );
}

/// Tinted affordance hinting the card opens a screen.
class _SectionChevron extends StatelessWidget {
  const _SectionChevron({required this.style});

  final PreviewSectionStyle style;

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: style.accentStart.withValues(alpha: 0.12),
    ),
    child: Icon(
      Icons.arrow_forward_rounded,
      size: 16,
      color: style.accentStart,
    ),
  );
}
