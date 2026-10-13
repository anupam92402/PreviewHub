import 'package:flutter/material.dart';

/// The hairline tying a widget group's rows together in the index.
class WidgetGroupRail extends StatelessWidget {
  /// Creates a rail drawn in [color].
  const WidgetGroupRail({
    required this.color,
    required this.stopsShort,
    super.key,
  });

  /// Colour of the line.
  final Color color;

  /// Whether the line ends partway down, under the last row of its group.
  final bool stopsShort;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.5,
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: stopsShort ? 0.6 : 1,
        child: ColoredBox(color: color, child: const SizedBox.expand()),
      ),
    );
  }
}
