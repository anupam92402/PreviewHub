import 'package:flutter/material.dart';

/// A rounded bar filled to [value], from 0 to 1.
class AssetSizeMeter extends StatelessWidget {
  /// Creates a bar filled to [value] in [color].
  const AssetSizeMeter({
    required this.value,
    required this.color,
    this.height = 6,
    super.key,
  });

  /// How full the bar is, from 0 to 1.
  final double value;

  /// Colour of the filled part.
  final Color color;

  /// Thickness of the bar.
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(height),
    child: SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: value.clamp(0, 1),
            child: ColoredBox(color: color),
          ),
        ],
      ),
    ),
  );
}
