import 'package:flutter/material.dart';

/// Stands in for an animation that could not be played: a glyph and a caption
/// that shrink to fit the box they are given, the caption dropping out when
/// there is no room for it.
class AnimationPlaybackFailure extends StatelessWidget {
  /// Creates a failure panel reading [message], tinted with [accent].
  const AnimationPlaybackFailure({
    required this.message,
    required this.accent,
    this.iconSize = 28,
    super.key,
  });

  /// Caption under the glyph.
  final String message;

  /// Colour of the glyph and caption.
  final Color accent;

  /// Largest the glyph is allowed to be.
  final double iconSize;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final double glyph = iconSize.clamp(
        12,
        constraints.biggest.shortestSide * 0.5,
      );
      final bool showCaption = constraints.maxHeight >= glyph * 2.4;

      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.motion_photos_off_outlined, size: glyph, color: accent),
          if (showCaption) ...<Widget>[
            SizedBox(height: glyph * 0.18),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: glyph * 0.36, color: accent),
              ),
            ),
          ],
        ],
      );
    },
  );
}
