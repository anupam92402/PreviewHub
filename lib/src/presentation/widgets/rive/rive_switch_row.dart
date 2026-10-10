import 'package:flutter/material.dart';

/// An on/off value in a Rive panel, as a labelled switch.
class RiveSwitchRow extends StatelessWidget {
  /// Creates the row for the value called [name].
  const RiveSwitchRow({
    required this.name,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Name the file gives the value.
  final String name;

  /// Current value.
  final bool value;

  /// Called with the new value.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: const EdgeInsets.only(right: 8),
    dense: true,
    title: Text(name),
    value: value,
    onChanged: onChanged,
  );
}
