import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// The design system's single-line text field. Draws its own container so
/// focus, error and disabled states are visible side by side. Supply a
/// [controller] to read the text; one is created and disposed internally when
/// none is given.
class AppTextField extends StatefulWidget {
  /// Creates a field labelled [label].
  const AppTextField({
    required this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialText,
    this.prefixIcon,
    this.enabled = true,
    this.obscurable = false,
    this.keyboardType,
    this.onChanged,
    super.key,
  });

  /// Caption above the field.
  final String label;

  /// Placeholder shown while the field is empty.
  final String? hintText;

  /// Message beneath the field when there is no error.
  final String? helperText;

  /// Message beneath the field, which also recolours the border.
  final String? errorText;

  /// Controller owning the text; created internally when null.
  final TextEditingController? controller;

  /// Text to start with, used only when [controller] is null.
  final String? initialText;

  /// Optional glyph inside the leading edge of the field.
  final IconData? prefixIcon;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether the text is hidden behind a reveal toggle.
  final bool obscurable;

  /// Keyboard to raise on focus.
  final TextInputType? keyboardType;

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

/// The border repaints on focus change; the field content is passed as the
/// builder's child so it is built once.
class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _hasFocus = ValueNotifier<bool>(false);
  late final ValueNotifier<bool> _obscured = ValueNotifier<bool>(
    widget.obscurable,
  );

  /// Only disposed when this state made it.
  TextEditingController? _ownedController;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownedController ??= TextEditingController(text: widget.initialText));

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() => _hasFocus.value = _focusNode.hasFocus;

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _hasFocus.dispose();
    _obscured.dispose();
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;
    final String? caption = widget.errorText ?? widget.helperText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: widget.enabled ? AppTokens.ink : AppTokens.disabledContent,
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<bool>(
          valueListenable: _hasFocus,
          builder: (BuildContext context, bool focused, Widget? child) {
            final Color border = !widget.enabled
                ? AppTokens.disabledOutline
                : hasError
                ? AppTokens.failure
                : focused
                ? AppTokens.primary
                : AppTokens.outline;

            return DecoratedBox(
              decoration: BoxDecoration(
                color: widget.enabled
                    ? AppTokens.surface
                    : AppTokens.secondarySoft,
                border: Border.all(color: border, width: focused ? 1.6 : 1),
                borderRadius: BorderRadius.circular(AppTokens.radius),
              ),
              child: child,
            );
          },
          child: ValueListenableBuilder<bool>(
            valueListenable: _obscured,
            builder: (BuildContext context, bool obscured, Widget? child) =>
                Row(
                  children: <Widget>[
                    if (widget.prefixIcon != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Icon(
                          widget.prefixIcon,
                          size: 19,
                          color: AppTokens.inkMuted,
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        obscureText: obscured,
                        keyboardType: widget.keyboardType,
                        onChanged: widget.onChanged,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTokens.ink,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: widget.hintText,
                          hintStyle: const TextStyle(
                            color: AppTokens.inkMuted,
                            fontSize: 15,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    if (widget.obscurable)
                      IconButton(
                        onPressed: widget.enabled
                            ? () => _obscured.value = !obscured
                            : null,
                        icon: Icon(
                          obscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 19,
                        ),
                        color: AppTokens.inkMuted,
                      ),
                  ],
                ),
          ),
        ),
        if (caption != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            caption,
            style: TextStyle(
              fontSize: 12.5,
              color: hasError ? AppTokens.failure : AppTokens.inkMuted,
            ),
          ),
        ],
      ],
    );
  }
}
