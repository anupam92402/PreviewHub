import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/asset_size_report.dart';
import '../theme/asset_size_style.dart';

/// The share of each category as a ring, drawn in on arrival. A tap on a
/// slice picks that category out.
class AssetSizeDonut extends StatelessWidget {
  /// Creates the ring over [report], with [centre] in its hole.
  const AssetSizeDonut({
    required this.report,
    required this.selected,
    required this.onSelect,
    required this.centre,
    super.key,
  });

  /// Side of the chart.
  static const double _size = 210;

  /// What is being charted.
  final AssetSizeReport report;

  /// Slice picked out, drawn thicker while the others fade; null for none.
  final AssetSizeCategory? selected;

  /// Called with the category whose slice was tapped.
  final ValueChanged<AssetSizeCategory> onSelect;

  /// Shown in the hole, such as the total.
  final Widget centre;

  /// Category under [position], or null for the hole and the corners.
  AssetSizeCategory? _hit(Offset position, List<AssetSizeCategory> slices) {
    const Offset middle = Offset(_size / 2, _size / 2);
    final Offset delta = position - middle;
    final double radius = delta.distance;
    if (radius < _size * 0.28 || radius > _size / 2) {
      return null;
    }
    double angle = math.atan2(delta.dy, delta.dx) + math.pi / 2;
    if (angle < 0) {
      angle += math.pi * 2;
    }
    final double at = angle / (math.pi * 2);
    double start = 0;
    for (final AssetSizeCategory category in slices) {
      start += report.shareOf(category);
      if (at <= start) {
        return category;
      }
    }
    return slices.lastOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final List<AssetSizeCategory> slices = report.presentCategories;
    final int? selectedIndex = selected == null
        ? null
        : slices.indexOf(selected!);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (TapUpDetails details) {
        final AssetSizeCategory? category = _hit(details.localPosition, slices);
        if (category != null) {
          onSelect(category);
        }
      },
      child: SizedBox.square(
        dimension: _size,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double progress, Widget? child) =>
              CustomPaint(
                painter: _DonutPainter(
                  slices: <(Color, double)>[
                    for (final AssetSizeCategory category in slices)
                      (
                        AssetSizeStyle.colorOf(category),
                        report.shareOf(category),
                      ),
                  ],
                  progress: progress,
                  selectedIndex: selectedIndex,
                  track: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: child,
              ),
          child: Center(child: centre),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.slices,
    required this.progress,
    required this.selectedIndex,
    required this.track,
  });

  /// Colour and share of each slice, clockwise from twelve o'clock.
  final List<(Color, double)> slices;

  /// How much of the ring is drawn, from 0 to 1.
  final double progress;

  /// Slice picked out, drawn thicker while the others fade.
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
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.track != track ||
      oldDelegate.slices.length != slices.length;
}
