import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';

/// A compact pill showing the playback speed, opening a menu of [speeds].
/// Sized to sit beside a compact `SegmentedButton`.
class LottieSpeedPicker extends StatelessWidget {
  /// Creates a picker showing [value].
  const LottieSpeedPicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Speeds offered, where 1 is the speed the animation was authored at.
  static const List<double> speeds = <double>[0.25, 0.5, 1, 1.5, 2];

  /// Speed in use.
  final double value;

  /// Called with the speed picked.
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return PopupMenuButton<double>(
      tooltip: PreviewHubStrings.lottieSpeed,
      initialValue: value,
      position: PopupMenuPosition.under,
      onSelected: onChanged,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
        for (final double speed in speeds)
          CheckedPopupMenuItem<double>(
            value: speed,
            checked: speed == value,
            child: Text(PreviewHubStrings.speedLabel(speed)),
          ),
      ],
      child: Container(
        height: 32,
        padding: const EdgeInsets.only(left: 12, right: 6),
        decoration: ShapeDecoration(
          shape: StadiumBorder(side: BorderSide(color: scheme.outline)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.speed_rounded, size: 18, color: scheme.onSurface),
            const SizedBox(width: 6),
            Text(
              PreviewHubStrings.speedLabel(value),
              style: theme.textTheme.labelLarge,
            ),
            Icon(Icons.arrow_drop_down_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
