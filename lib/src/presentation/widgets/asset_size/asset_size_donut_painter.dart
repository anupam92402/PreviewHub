import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints the asset-size ring: an empty track, then one arc per slice
/// clockwise from twelve o'clock, with the picked slice thicker and the
/// others faded.
class AssetSizeDonutPainter extends CustomPainter {
  /// Creates a painter for [slices], drawn [progress] of the way round.
  const AssetSizeDonutPainter({
    required this.slices,
    required this.progress,
    required this.selectedIndex,
    required this.track,
  });

  /// Colour and share of each slice, clockwise from twelve o'clock.
  final List<(Color, double)> slices;

  /// How much of the ring is drawn, from 0 to 1.
  final double progress;

  /// Slice picked out, drawn thicker while the others fade; null for none.
  final int? selectedIndex;

  /// Colour of the empty ring behind the slices.
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.shortestSide * 0.15;
    final Rect ring = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - stroke * 0.7,
    );
    canvas.drawArc(
      ring,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    final double gap = slices.length > 1 ? 0.035 : 0;
    double start = -math.pi / 2;
    for (int i = 0; i < slices.length; i++) {
      final (Color color, double share) = slices[i];
      final double sweep = share * math.pi * 2 * progress;
      final bool picked = selectedIndex == i;
      final bool faded = selectedIndex != null && !picked;
      if (sweep > gap) {
        canvas.drawArc(
          ring,
          start + gap / 2,
          sweep - gap,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = picked ? stroke * 1.3 : stroke
            ..color = faded ? color.withValues(alpha: 0.3) : color,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(AssetSizeDonutPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.track != track ||
      oldDelegate.slices.length != slices.length;
}
