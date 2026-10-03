import 'package:flutter/material.dart';

/// A glyph and a sentence centred on a screen, for its empty and failed
/// states.
class StatusMessage extends StatelessWidget {
  /// Shows [message] under [icon].
  const StatusMessage({required this.icon, required this.message, super.key});

  /// Glyph above the sentence.
  final IconData icon;

  /// What happened.
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 34, color: scheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
