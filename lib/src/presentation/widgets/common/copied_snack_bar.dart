import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../util/preview_hub_strings.dart';

/// The brief floating confirmation shown after something is copied.
class CopiedSnackBar extends SnackBar {
  /// Creates the confirmation reading [message].
  CopiedSnackBar({String message = PreviewHubStrings.copied, super.key})
    : super(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      );

  /// Puts [text] on the clipboard and confirms it with [message].
  static void copy(
    BuildContext context,
    String text, {
    String message = PreviewHubStrings.copied,
  }) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(CopiedSnackBar(message: message));
  }
}
