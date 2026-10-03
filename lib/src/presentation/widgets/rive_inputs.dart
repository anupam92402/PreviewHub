import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import '../../preview_hub_strings.dart';
import 'rive_number_input.dart';

/// Every input the state machine declares, each as a control: a switch for a
/// boolean, a stepper for a number, a button for a trigger.
///
/// Rive now recommends data binding over state machine inputs, which is why
/// the input API is marked deprecated, but inputs remain how most shipped
/// files are driven, so they are what the gallery exposes.
class RiveInputs extends StatefulWidget {
  /// Creates the controls for [controller]'s state machine.
  const RiveInputs({required this.controller, super.key});

  /// Controller whose state machine inputs are shown.
  final rive.RiveWidgetController controller;

  @override
  State<RiveInputs> createState() => _RiveInputsState();
}

class _RiveInputsState extends State<RiveInputs> {
  /// Bumped whenever an input changes, so the controls redraw its new value.
  final ValueNotifier<int> _revision = ValueNotifier<int>(0);

  // ignore: deprecated_member_use
  late final List<rive.Input> _inputs = widget.controller.stateMachine.inputs;

  @override
  void dispose() {
    _revision.dispose();
    super.dispose();
  }

  void _changed() {
    widget.controller.scheduleRepaint();
    _revision.value++;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: ValueListenableBuilder<int>(
            valueListenable: _revision,
            builder: (BuildContext context, int revision, Widget? child) =>
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      PreviewHubStrings.riveInputs,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_inputs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 8),
                        child: Text(
                          PreviewHubStrings.riveNoInputs,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    for (final rive.Input input in _inputs)
                      switch (input) {
                        final rive.BooleanInput input => SwitchListTile(
                          contentPadding: const EdgeInsets.only(right: 8),
                          dense: true,
                          title: Text(input.name),
                          value: input.value,
                          onChanged: (bool value) {
                            input.value = value;
                            _changed();
                          },
                        ),
                        final rive.NumberInput input => RiveNumberInput(
                          name: input.name,
                          value: input.value,
                          onChanged: (double value) {
                            input.value = value;
                            _changed();
                          },
                        ),
                        final rive.TriggerInput input => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: <Widget>[
                              Expanded(child: Text(input.name)),
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  input.fire();
                                  _changed();
                                },
                                icon: const Icon(Icons.bolt_rounded, size: 18),
                                label: const Text(PreviewHubStrings.riveFire),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        _ => const SizedBox.shrink(),
                      },
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
