import 'package:flutter/material.dart';

import '../../preview_hub_strings.dart';

/// A row of colour dots choosing how artwork is tinted, led by a "no tint"
/// dot. Tinting fills the artwork's shape the way an `IconTheme` tints an
/// icon, which shows whether a monochrome asset takes a colour cleanly.
class AssetTintPicker extends StatelessWidget {
  /// Creates the picker showing [value] among [choices].
  const AssetTintPicker({
    required this.value,
    required this.onChanged,
    this.choices = defaultChoices,
    super.key,
  });

  /// Colours offered besides no tint: ink, white, and the usual accents.
  static const List<Color> defaultChoices = <Color>[
    Color(0xFF111827),
    Color(0xFFFFFFFF),
    Color(0xFF2563EB),
    Color(0xFFDC2626),
    Color(0xFF16A34A),
    Color(0xFFD97706),
  ];

  /// Tint in use, or null for none.
  final Color? value;

  /// Called with the tint picked, or null for none.
  final ValueChanged<Color?> onChanged;

  /// Colours offered besides no tint.
  final List<Color> choices;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          PreviewHubStrings.assetTint,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        _TintDot(
          color: null,
          selected: value == null,
          onTap: () => onChanged(null),
        ),
        for (final Color color in choices)
          _TintDot(
            color: color,
            selected: value == color,
            onTap: () => onChanged(color),
          ),
      ],
    );
  }
}

/// One tint choice; null is drawn as a struck-through circle.
class _TintDot extends StatelessWidget {
  const _TintDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color? color;
  final bool selected;
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
