import 'package:flutter/material.dart';

import 'shimmer_border_ray.dart';

/// A short ray of light travelling round the outline of [child], one lap at a
/// time with a short rest between laps, so it reads as a shimmer rather than a
/// spinner. The ray fades in as a lap starts and out as it ends, and eases
/// round rather than moving at a constant speed. Only the ray moves, and it
/// costs no rebuilds: it is a childless painter laid over [child] in a repaint
/// layer of its own, driven straight from the animation, so each frame
/// repaints that one layer and nothing else is built, laid out or painted
/// again. [child] is drawn once and reused. The ray rests while a route covers
/// this one, since Flutter mutes the tickers of a route that cannot be seen,
/// and picks up again on return. It is left out entirely when the platform
/// asks for reduced motion.
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
        child: ShimmerBorderRay(
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
