import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';

/// One tint choice in the asset tint picker; a null [color] is drawn as a
/// struck-through circle meaning no tint.
class AssetTintDot extends StatelessWidget {
  /// Creates the dot for [color], ringed when [selected].
  const AssetTintDot({
    required this.color,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// Tint this dot offers, or null for none.
  final Color? color;

  /// Whether this tint is the one in use.
  final bool selected;

  /// Called when the dot is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: color == null
          ? PreviewHubStrings.assetTintNone
          : PreviewHubStrings.assetTint,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color ?? scheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? scheme.primary : scheme.outlineVariant,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: color == null
                ? Icon(
                    Icons.block_rounded,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
