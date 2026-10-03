import 'package:flutter/material.dart';

/// Soft halo that gives the dashboard header some depth.
class DashboardHeaderGlow extends StatelessWidget {
  /// Creates a halo tinted with [color].
  const DashboardHeaderGlow({required this.color, super.key});

  /// Colour at the centre of the halo, fading to clear at its edge.
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 240,
    height: 240,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: <Color>[
          color.withValues(alpha: 0.20),
          color.withValues(alpha: 0),
        ],
      ),
    ),
  );
}
