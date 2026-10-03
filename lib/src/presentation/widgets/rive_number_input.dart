import 'package:flutter/material.dart';

import '../../preview_hub_strings.dart';

/// A number input: its value, steppers either side, and a field for an exact
/// value. A state machine declares no range, so a slider would be a guess.
class RiveNumberInput extends StatefulWidget {
  /// Creates the control for the input called [name], showing [value].
  const RiveNumberInput({
    required this.name,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Name the state machine gives the input.
  final String name;

  /// Current value of the input.
  final double value;

  /// Called with the new value.
  final ValueChanged<double> onChanged;

  @override
  State<RiveNumberInput> createState() => _RiveNumberInputState();
}

class _RiveNumberInputState extends State<RiveNumberInput> {
  late final TextEditingController _text = TextEditingController(
    text: _format(widget.value),
  );

  static String _format(double value) => value == value.roundToDouble()
      ? '${value.round()}'
      : value.toStringAsFixed(2);

  @override
  void didUpdateWidget(RiveNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _text.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit(String text) {
    final double? parsed = double.tryParse(text);
    if (parsed != null) {
      widget.onChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: <Widget>[
        Expanded(child: Text(widget.name)),
        IconButton(
          tooltip: PreviewHubStrings.riveDecrease,
          onPressed: () => widget.onChanged(widget.value - 1),
          icon: const Icon(Icons.remove_rounded, size: 18),
        ),
        SizedBox(
          width: 64,
          child: TextField(
            controller: _text,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onSubmitted: _submit,
          ),
        ),
        IconButton(
          tooltip: PreviewHubStrings.riveIncrease,
          onPressed: () => widget.onChanged(widget.value + 1),
          icon: const Icon(Icons.add_rounded, size: 18),
        ),
      ],
    ),
  );
}
