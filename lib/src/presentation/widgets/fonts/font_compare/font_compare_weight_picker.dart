import 'package:flutter/material.dart';

import '../../../../util/preview_hub_strings.dart';

/// A menu of the nine standard weights, shared by both sides of the
/// comparison.
class FontCompareWeightPicker extends StatelessWidget {
  /// Creates the menu writing its choice to [selection].
  const FontCompareWeightPicker({required this.selection, super.key});

  /// Weight both families are set in.
  final ValueNotifier<FontWeight> selection;

  @override
  Widget build(BuildContext context) => DropdownMenu<FontWeight>(
    label: const Text(PreviewHubStrings.fontFieldWeight),
    width: 116,
    initialSelection: selection.value,
    onSelected: (FontWeight? weight) {
      if (weight != null) {
        selection.value = weight;
      }
    },
    dropdownMenuEntries: <DropdownMenuEntry<FontWeight>>[
      for (final FontWeight weight in FontWeight.values)
        DropdownMenuEntry<FontWeight>(value: weight, label: '${weight.value}'),
    ],
  );
}
