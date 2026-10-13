import 'package:flutter/material.dart';

import '../../../preview_section.dart';
import '../../../util/preview_hub_colors.dart';

/// Gradient tile carrying a section glyph, at the start of a preview section
/// card.
class PreviewSectionCardBadge extends StatelessWidget {
  /// Creates the tile in [style].
  const PreviewSectionCardBadge({required this.style, super.key});

  /// Look of the section, giving the gradient, glow and glyph.
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
    child: Icon(style.icon, color: PreviewHubColors.white, size: 26),
  );
}
