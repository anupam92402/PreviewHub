import 'package:flutter/material.dart';

import '../preview_backdrop.dart';

/// Segments choosing a [PreviewBackdrop].
class PreviewBackdropPicker extends StatelessWidget {
  /// Creates a picker showing [value].
  const PreviewBackdropPicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Backdrop in use.
  final PreviewBackdrop value;

  /// Called with the backdrop picked.
  final ValueChanged<PreviewBackdrop> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<PreviewBackdrop>(
    showSelectedIcon: false,
    style: const ButtonStyle(visualDensity: VisualDensity.compact),
    segments: <ButtonSegment<PreviewBackdrop>>[
      for (final PreviewBackdrop backdrop in PreviewBackdrop.values)
        ButtonSegment<PreviewBackdrop>(
          value: backdrop,
          tooltip: backdrop.label,
          icon: Icon(backdrop.icon, size: 18),
        ),
    ],
    selected: <PreviewBackdrop>{value},
    onSelectionChanged: (Set<PreviewBackdrop> next) => onChanged(next.single),
  );
}
