import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A short ray of light travelling round the outline of [child], one lap at a
/// time with a short rest between laps, so it reads as a shimmer rather than a
/// spinner. The ray fades in as a lap starts and out as it ends, and eases
/// round rather than moving at a constant speed.
///
/// Only the ray moves, and it costs no rebuilds: it is a childless painter laid
/// over [child] in a repaint layer of its own, driven straight from the
/// animation, so each frame repaints that one layer and nothing else is built,
/// laid out or painted again. [child] is drawn once and reused.
///
/// The ray rests while a route covers this one, since Flutter mutes the tickers
/// of a route that cannot be seen, and picks up again on return. It is left out
/// entirely when the platform asks for reduced motion.
class ShimmerBorder extends StatelessWidget {
  /// Runs a ray round [child]'s outline, a rounded rectangle of [radius].
  const ShimmerBorder({
    required this.child,
    required this.color,
    this.radius = 100,
    this.strokeWidth = 2,
    this.lap = const Duration(milliseconds: 3600),
    this.pause = const Duration(milliseconds: 1500),
    super.key,
  });

  /// What the ray runs round; its outline should match [radius].
  final Widget child;

  /// Colour at the bright head of the ray.
  final Color color;

  /// Corner radius of the outline; a large value gives a pill.
  final double radius;

  /// Thickness of the ray.
  final double strokeWidth;

  /// How long the ray takes to go once round.
  final Duration lap;

  /// How long the outline rests between laps.
  final Duration pause;

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      child,
      Positioned.fill(
        child: _Ray(
          color: color,
          radius: radius,
          strokeWidth: strokeWidth,
          lap: lap,
          pause: pause,
        ),
      ),
    ],
  );
}

/// The moving ray itself: owns the animation and nothing else. One cycle of
/// the animation is a lap followed by the rest, so a single repeating
/// controller covers both.
class _Ray extends StatefulWidget {
  const _Ray({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.lap,
    required this.pause,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final Duration lap;
  final Duration pause;

  /// Length of one lap plus its rest.
  Duration get cycle => lap + pause;

  /// Share of each cycle spent moving, from 0 to 1.
  double get movingShare =>
      cycle == Duration.zero ? 1 : lap.inMicroseconds / cycle.inMicroseconds;

  @override
  State<_Ray> createState() => _RayState();
}

class _RayState extends State<_Ray> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(_Ray oldWidget) {
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
          painter: _RayPainter(
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

/// Strokes the outline with a sweep gradient that is clear everywhere but a
/// band of [color], turned a little further each frame. Draws nothing while
/// the outline is resting.
class _RayPainter extends CustomPainter {
  _RayPainter({
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

  final Color color;
  final double radius;
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
  bool shouldRepaint(_RayPainter oldDelegate) =>
      oldDelegate.movingShare != movingShare ||
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.lap != lap;
}
