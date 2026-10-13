import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rive/rive.dart' as rive;

import '../../../util/preview_hub_strings.dart';
import 'rive_number_input.dart';
import 'rive_panel_card.dart';
import 'rive_panel_message.dart';
import 'rive_switch_row.dart';
import 'rive_trigger_row.dart';

/// Every input the state machine declares, each as a control: a switch for a
/// boolean, a stepper for a number, a button for a trigger. Rive now
/// recommends data binding over state machine inputs, which is why the input
/// API is marked deprecated, but inputs remain how most shipped files are
/// driven, so they are what the gallery exposes.
class RiveInputs extends StatefulWidget {
  /// Creates the controls for [controller]'s state machine.
  const RiveInputs({required this.controller, super.key});

  /// Controller whose state machine inputs are shown.
  final rive.RiveWidgetController controller;

  @override
  State<RiveInputs> createState() => _RiveInputsState();
}

class _RiveInputsState extends State<RiveInputs>
    with SingleTickerProviderStateMixin {
  /// Bumped whenever an input changes, so the controls redraw its new value.
  final ValueNotifier<int> _revision = ValueNotifier<int>(0);

  // ignore: deprecated_member_use
  late final List<rive.Input> _inputs = widget.controller.stateMachine.inputs;

  /// Reads the inputs every frame, since the animation itself can change
  /// them: a tap on the artboard, or a state that sets an input on entry.
  /// Created only when there is a value to follow; triggers hold none.
  Ticker? _ticker;

  /// Values the controls were last drawn with, in the order of [_inputs].
  late List<Object> _drawn = _values();

  @override
  void initState() {
    super.initState();
    if (_inputs.any((rive.Input input) => input is! rive.TriggerInput)) {
      _ticker = createTicker(_poll)..start();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _revision.dispose();
    super.dispose();
  }

  /// The current value of every input; a trigger holds none, so it reads as a
  /// fixed placeholder.
  List<Object> _values() => <Object>[
    for (final rive.Input input in _inputs)
      switch (input) {
        final rive.BooleanInput input => input.value,
        final rive.NumberInput input => input.value,
        _ => 0,
      },
  ];

  /// Redraws the controls when the animation has changed an input since they
  /// were last drawn. Skipped while paused, when nothing can change one.
  void _poll(Duration elapsed) {
    if (!widget.controller.active) {
      return;
    }
    final List<Object> current = _values();
    if (!listEquals(current, _drawn)) {
      _drawn = current;
      _revision.value++;
    }
  }

  /// Repaints after a control changed an input and redraws the controls.
  void _changed() {
    widget.controller.scheduleRepaint();
    _drawn = _values();
    _revision.value++;
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: _revision,
    builder: (BuildContext context, int revision, Widget? child) =>
        RivePanelCard(
          title: PreviewHubStrings.riveInputs,
          children: <Widget>[
            if (_inputs.isEmpty)
              const RivePanelMessage(message: PreviewHubStrings.riveNoInputs),
            for (final rive.Input input in _inputs)
              switch (input) {
                final rive.BooleanInput input => RiveSwitchRow(
                  name: input.name,
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
                final rive.TriggerInput input => RiveTriggerRow(
                  name: input.name,
                  onFire: () {
                    input.fire();
                    _changed();
                  },
                ),
                _ => const SizedBox.shrink(),
              },
          ],
        ),
  );
}
