import 'package:flutter/material.dart';

import 'shimmer_border_ray_painter.dart';

/// The moving ray of a shimmer border: owns the animation and nothing else.
/// One cycle of the animation is a lap followed by the rest, so a single
/// repeating controller covers both.
class ShimmerBorderRay extends StatefulWidget {
  /// Creates a ray of [color] running round a rounded rectangle of [radius].
  const ShimmerBorderRay({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.lap,
    required this.pause,
    super.key,
  });

  /// Colour at the bright head of the ray.
  final Color color;

  /// Corner radius of the outline.
  final double radius;

  /// Thickness of the ray.
  final double strokeWidth;

  /// How long the ray takes to go once round.
  final Duration lap;

  /// How long the outline rests between laps.
  final Duration pause;

  /// Length of one lap plus its rest.
  Duration get cycle => lap + pause;

  /// Share of each cycle spent moving, from 0 to 1.
  double get movingShare =>
      cycle == Duration.zero ? 1 : lap.inMicroseconds / cycle.inMicroseconds;

  @override
  State<ShimmerBorderRay> createState() => _ShimmerBorderRayState();
}

class _ShimmerBorderRayState extends State<ShimmerBorderRay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lap = AnimationController(
    vsync: this,
    duration: widget.cycle,
  );

  /// Starts or stops the lap to follow the platform's reduced-motion setting,
  /// which can change while the screen is up.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _lap.stop();
    } else if (!_lap.isAnimating) {
      _lap.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerBorderRay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cycle != oldWidget.cycle) {
      _lap.duration = widget.cycle;
      if (_lap.isAnimating) {
        _lap.repeat();
      }
    }
  }

  @override
  void dispose() {
    _lap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: ShimmerBorderRayPainter(
            lap: _lap,
            movingShare: widget.movingShare,
            color: widget.color,
            radius: widget.radius,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}
