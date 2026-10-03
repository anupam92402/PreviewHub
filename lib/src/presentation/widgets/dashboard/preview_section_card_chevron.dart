import 'package:flutter/material.dart';

import '../../../preview_section.dart';

/// Tinted affordance at the end of a preview section card, hinting the card
/// opens a screen.
class PreviewSectionCardChevron extends StatelessWidget {
  /// Creates the affordance tinted from [style].
  const PreviewSectionCardChevron({required this.style, super.key});

  /// Look of the section, giving the tint.
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
