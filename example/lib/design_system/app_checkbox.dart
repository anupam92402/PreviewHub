import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// A labelled checkbox with optional tristate and error styling.
///
/// The control is fully controlled: it draws [value] and reports taps through
/// [onChanged], so the caller owns the state. A null [onChanged] disables it.
class AppCheckbox extends StatelessWidget {
  /// Creates a checkbox labelled [label].
  const AppCheckbox({
    required this.label,
    required this.value,
    this.onChanged,
    this.tristate = false,
    this.errorText,
    this.helperText,
    super.key,
  });

  /// Words beside the box.
  final String label;

  /// Checked, unchecked, or null for the indeterminate state.
  final bool? value;

  /// Called with the next value on tap; null disables the control.
  final ValueChanged<bool?>? onChanged;

  /// Whether tapping cycles through the indeterminate state.
  final bool tristate;

  /// Message shown beneath the label, which also recolours the box.
  final String? errorText;

  /// Message shown beneath the label when there is no error.
  final String? helperText;

  /// The value a tap moves to, following Flutter's own tristate order.
  bool? get _nextValue {
    if (tristate) {
      return switch (value) {
        false => true,
        true => null,
        null => false,
      };
    }
    return !(value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    final bool hasError = errorText != null;
    final bool marked = value ?? true;
    final Color accent = hasError ? AppTokens.failure : AppTokens.primary;
    final String? caption = errorText ?? helperText;

    return InkWell(
      onTap: enabled ? () => onChanged!(_nextValue) : null,
      borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _CheckboxBox(
              value: value,
              accent: accent,
              enabled: enabled,
              marked: marked,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      color: enabled
                          ? AppTokens.ink
                          : AppTokens.disabledContent,
                    ),
                  ),
                  if (caption != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      caption,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: hasError
                            ? AppTokens.failure
                            : AppTokens.inkMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The 22pt box itself, filled once the value is anything but false.
class _CheckboxBox extends StatelessWidget {
  const _CheckboxBox({
    required this.value,
    required this.accent,
    required this.enabled,
    required this.marked,
  });

  final bool? value;
  final Color accent;
  final bool enabled;
  final bool marked;

  @override
  Widget build(BuildContext context) {
    final Color fill = !marked
        ? AppTokens.surface
        : enabled
        ? accent
        : AppTokens.disabledFill;
    final Color border = !enabled
        ? AppTokens.disabledOutline
        : marked
        ? accent
        : AppTokens.outline;

    return Container(
      width: 22,
      height: 22,
      // Nudged down so the box sits on the label's first line rather than
      // above it once the label wraps.
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
      ),
      child: marked
          ? Icon(
              value == null ? Icons.remove_rounded : Icons.check_rounded,
              size: 16,
              color: enabled ? AppTokens.onAccent : AppTokens.disabledContent,
            )
          : null,
    );
  }
}
