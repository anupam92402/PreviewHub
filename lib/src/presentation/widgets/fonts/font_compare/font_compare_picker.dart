import 'package:flutter/material.dart';

import '../../../../domain/models/font_family_info.dart';

/// A menu of every family, each entry set in itself, choosing one side of the
/// comparison.
class FontComparePicker extends StatelessWidget {
  /// Creates the menu labelled [label], writing its choice to [selection].
  const FontComparePicker({
    required this.label,
    required this.families,
    required this.selection,
    super.key,
  });

  /// Names the side the menu chooses.
  final String label;

  /// Families on offer.
  final List<FontFamilyInfo> families;

  /// Family chosen for this side.
  final ValueNotifier<FontFamilyInfo> selection;

  @override
  Widget build(BuildContext context) => DropdownMenu<FontFamilyInfo>(
    label: Text(label),
    expandedInsets: EdgeInsets.zero,
    initialSelection: selection.value,
    onSelected: (FontFamilyInfo? family) {
      if (family != null) {
        selection.value = family;
      }
    },
    dropdownMenuEntries: <DropdownMenuEntry<FontFamilyInfo>>[
      for (final FontFamilyInfo family in families)
        DropdownMenuEntry<FontFamilyInfo>(
          value: family,
          label: family.name,
          labelWidget: Text(
            family.name,
            style: TextStyle(fontFamily: family.manifestKey),
          ),
        ),
    ],
  );
}
