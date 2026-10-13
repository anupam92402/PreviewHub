import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';

/// A trigger in a Rive panel: its name and a button that fires it.
class RiveTriggerRow extends StatelessWidget {
  /// Creates the row for the trigger called [name].
  const RiveTriggerRow({required this.name, required this.onFire, super.key});

  /// Name the file gives the trigger.
  final String name;

  /// Called when the button is pressed.
  final VoidCallback onFire;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: <Widget>[
        Expanded(child: Text(name)),
        FilledButton.tonalIcon(
          onPressed: onFire,
          icon: const Icon(Icons.bolt_rounded, size: 18),
          label: const Text(PreviewHubStrings.riveFire),
        ),
        const SizedBox(width: 8),
      ],
    ),
  );
}
