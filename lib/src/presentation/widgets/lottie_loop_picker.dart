import 'package:flutter/material.dart';

import '../../preview_hub_strings.dart';

/// Segments choosing whether an animation plays on repeat or once.
class LottieLoopPicker extends StatelessWidget {
  /// Creates a picker showing [loop].
  const LottieLoopPicker({
    required this.loop,
    required this.onChanged,
    super.key,
  });

  /// Whether the animation plays on repeat rather than once.
  final bool loop;

  /// Called with true for repeat, false for once.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<bool>(
    showSelectedIcon: false,
    segments: const <ButtonSegment<bool>>[
      ButtonSegment<bool>(
        value: true,
        icon: Icon(Icons.repeat_rounded, size: 18),
        label: Text(PreviewHubStrings.lottieLoop),
      ),
      ButtonSegment<bool>(
        value: false,
        icon: Icon(Icons.redo_rounded, size: 18),
        label: Text(PreviewHubStrings.lottieOnce),
      ),
    ],
    selected: <bool>{loop},
    onSelectionChanged: (Set<bool> next) => onChanged(next.single),
  );
}
