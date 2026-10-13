import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../util/preview_hub_strings.dart';

/// An icon button that copies [text] and confirms in place: its icon turns into
/// a tick for a moment. Works inside a bottom sheet, where a snackbar would be
/// hidden behind the sheet.
class CopyButton extends StatefulWidget {
  /// Creates a button copying [text], labelled [tooltip].
  const CopyButton({
    required this.text,
    this.tooltip = PreviewHubStrings.copy,
    this.size = 17,
    this.color,
    super.key,
  });

  /// What is put on the clipboard.
  final String text;

  /// Label for the button, also read by screen readers.
  final String tooltip;

  /// Size of the icon.
  final double size;

  /// Colour of the icon, or null for the theme's.
  final Color? color;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  /// How long the tick stays before the copy icon returns.
  static const Duration _confirmation = Duration(milliseconds: 1500);

  final ValueNotifier<bool> _copied = ValueNotifier<bool>(false);
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    _copied.dispose();
    super.dispose();
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.text));
    _copied.value = true;
    _reset?.cancel();
    _reset = Timer(_confirmation, () => _copied.value = false);
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: _copied,
    builder: (BuildContext context, bool copied, Widget? child) => IconButton(
      tooltip: copied ? PreviewHubStrings.copied : widget.tooltip,
      visualDensity: VisualDensity.compact,
      iconSize: widget.size,
      color: widget.color,
      onPressed: _copy,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: Icon(
          copied ? Icons.check_rounded : Icons.copy_rounded,
          key: ValueKey<bool>(copied),
        ),
      ),
    ),
  );
}
