import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Strokes a shimmer border's outline with a sweep gradient that is clear
/// everywhere but a band of [color], turned a little further each frame.
/// Draws nothing while the outline is resting.
class ShimmerBorderRayPainter extends CustomPainter {
  /// Creates a painter that repaints whenever [lap] ticks.
  ShimmerBorderRayPainter({
    required this.lap,
    required this.movingShare,
    required this.color,
    required this.radius,
    required this.strokeWidth,
  }) : super(repaint: lap);

  /// Share of each lap spent fading in at its start, and again fading out at
  /// its end.
  static const double _fade = 0.15;

  /// Where the band starts brightening, peaks and ends, as shares of a full
  /// turn: the band covers about two fifths of the outline.
  static const List<double> _bandStops = <double>[0, 0.58, 0.9, 1];

  /// Progress through one lap and its rest, from 0 to 1. Repaints the painter
  /// directly.
  final Animation<double> lap;

  /// Share of [lap] spent moving; the rest is the pause.
  final double movingShare;

  /// Colour at the bright head of the ray.
  final Color color;

  /// Corner radius of the outline, capped at half the shortest side.
  final double radius;

  /// Thickness of the ray.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (lap.value >= movingShare) {
      return;
    }
    final double t = lap.value / movingShare;
    final double opacity = math.min(1, math.min(t, 1 - t) / _fade);
    final double turn = Curves.easeInOut.transform(t);
    final Rect bounds = Offset.zero & size;
    final RRect outline = RRect.fromRectAndRadius(
      bounds.deflate(strokeWidth / 2),
      Radius.circular(math.min(radius, size.shortestSide / 2)),
    );
    final Color clear = color.withValues(alpha: 0);
    final Paint band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: <Color>[
          clear,
          clear,
          color.withValues(alpha: 0.9 * opacity),
          clear,
        ],
        stops: _bandStops,
        transform: GradientRotation(turn * math.pi * 2),
      ).createShader(bounds);
    canvas.drawRRect(outline, band);
  }

  @override
  bool shouldRepaint(ShimmerBorderRayPainter oldDelegate) =>
      oldDelegate.movingShare != movingShare ||
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.lap != lap;
}
