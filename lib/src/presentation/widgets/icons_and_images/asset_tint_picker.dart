import 'package:flutter/material.dart';

import '../../../util/preview_hub_colors.dart';
import '../../../util/preview_hub_strings.dart';
import 'asset_tint_dot.dart';

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
    PreviewHubColors.tintInk,
    PreviewHubColors.white,
    PreviewHubColors.tintBlue,
    PreviewHubColors.tintRed,
    PreviewHubColors.tintGreen,
    PreviewHubColors.tintAmber,
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
        AssetTintDot(
          color: null,
          selected: value == null,
          onTap: () => onChanged(null),
        ),
        for (final Color color in choices)
          AssetTintDot(
            color: color,
            selected: value == color,
            onTap: () => onChanged(color),
          ),
      ],
    );
  }
}
