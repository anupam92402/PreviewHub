import 'package:flutter/material.dart';

import '../../../../util/preview_hub_colors.dart';
import '../preview_backdrop.dart';
import 'checkerboard_painter.dart';

/// The panel an asset is drawn in, painted per [backdrop].
class PreviewBackdropBox extends StatelessWidget {
  /// Paints [backdrop] behind [child], tinted with [accent] on the surface.
  const PreviewBackdropBox({
    required this.backdrop,
    required this.accent,
    required this.child,
    this.height = 280,
    this.failed = false,
    super.key,
  });

  /// What to paint.
  final PreviewBackdrop backdrop;

  /// Tint of the gallery panel and its border.
  final Color accent;

  /// The artwork.
  final Widget child;

  /// Height of the panel.
  final double height;

  /// Whether the artwork failed, which always shows the tinted panel so the
  /// failure reads as one.
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final PreviewBackdrop effective = failed
        ? PreviewBackdrop.surface
        : backdrop;
    final BorderRadius radius = BorderRadius.circular(20);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: switch (effective) {
          PreviewBackdrop.surface => accent.withValues(
            alpha: failed ? 0.10 : 0.07,
          ),
          PreviewBackdrop.checker => PreviewHubColors.white,
          PreviewBackdrop.light => PreviewHubColors.white,
          PreviewBackdrop.dark => PreviewHubColors.backdropDark,
        },
        borderRadius: radius,
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: effective == PreviewBackdrop.checker
            ? const CheckerboardPainter()
            : null,
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }
}
