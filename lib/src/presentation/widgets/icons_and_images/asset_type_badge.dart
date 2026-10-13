import 'package:flutter/material.dart';

import '../../../util/preview_hub_colors.dart';

/// Format capsule on an asset tile, coloured so a type is recognisable
/// without reading it.
class AssetTypeBadge extends StatelessWidget {
  /// Creates a capsule reading [label] on an [accent] fill.
  const AssetTypeBadge({required this.label, required this.accent, super.key});

  /// Format name shown in the capsule.
  final String label;

  /// Fill colour of the capsule.
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: accent,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        color: PreviewHubColors.white,
      ),
    ),
  );
}
