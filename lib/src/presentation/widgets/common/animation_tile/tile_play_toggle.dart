import 'package:flutter/material.dart';

import '../../../../util/preview_hub_strings.dart';

/// A small round button on a grid tile that holds and resumes its animation
/// without leaving the grid.
class TilePlayToggle extends StatelessWidget {
  /// Creates the toggle flipping [isPlaying], drawn in [accent].
  const TilePlayToggle({
    required this.isPlaying,
    required this.accent,
    super.key,
  });

  /// Whether the animation is running.
  final ValueNotifier<bool> isPlaying;

  /// Colour of the glyph.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: isPlaying,
      builder: (BuildContext context, bool playing, Widget? child) => Material(
        color: scheme.surface.withValues(alpha: 0.85),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: playing
              ? PreviewHubStrings.lottiePause
              : PreviewHubStrings.lottiePlay,
          iconSize: 15,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          padding: EdgeInsets.zero,
          onPressed: () => isPlaying.value = !playing,
          icon: Icon(
            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: accent,
          ),
        ),
      ),
    );
  }
}
