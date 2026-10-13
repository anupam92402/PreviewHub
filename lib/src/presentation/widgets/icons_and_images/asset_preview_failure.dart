import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';

/// Stands in for artwork that could not be drawn. Sizes itself to whatever box
/// it is handed, since a fixed glyph and caption do not fit the few dozen
/// pixels a tile gets at four per row.
class AssetPreviewFailure extends StatelessWidget {
  /// Creates a failure panel tinted with [accent].
  const AssetPreviewFailure({
    required this.accent,
    this.message = PreviewHubStrings.assetLoadFailed,
    this.iconSize = 28,
    super.key,
  });

  /// Colour of the glyph and caption.
  final Color accent;

  /// Caption under the glyph.
  final String message;

  /// Largest the glyph is allowed to be.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double shortest = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final double glyph = math.min(iconSize, shortest * 0.5);
        final double fontSize = math.max(9, glyph * 0.39);
        final bool showCaption =
            constraints.maxHeight >= glyph + fontSize * 2.4;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.quiz_outlined, size: glyph, color: accent),
            if (showCaption) ...<Widget>[
              SizedBox(height: glyph * 0.18),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: fontSize, color: accent),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
