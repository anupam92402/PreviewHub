import 'package:flutter/material.dart';

import '../../../domain/models/preview_asset.dart';
import 'asset_preview.dart';

/// The same artwork side by side at each of [sizes], each captioned with its
/// size, to show how it holds up at the sizes icons really ship at. Centred in
/// the room it is given.
class AssetPreviewRamp extends StatelessWidget {
  /// Draws [asset] at every one of [sizes], tinted with [tint].
  const AssetPreviewRamp({
    required this.asset,
    this.tint,
    this.sizes = defaultSizes,
    super.key,
  });

  /// Sizes drawn by default, in logical pixels.
  static const List<double> defaultSizes = <double>[16, 24, 32, 40, 48];

  /// Artwork drawn.
  final PreviewAsset asset;

  /// Colour to fill the artwork with, or null to draw it as authored.
  final Color? tint;

  /// Sizes to draw it at, in logical pixels.
  final List<double> sizes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (int i = 0; i < sizes.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 22),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox.square(
                dimension: sizes[i],
                child: AssetPreview(asset: asset, tint: tint),
              ),
              const SizedBox(height: 6),
              Text(
                '${sizes[i].toInt()}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
