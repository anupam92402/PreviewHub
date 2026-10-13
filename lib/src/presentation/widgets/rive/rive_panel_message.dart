import 'package:flutter/material.dart';

/// A muted sentence inside a Rive panel card, for when it has nothing to list.
class RivePanelMessage extends StatelessWidget {
  /// Shows [message].
  const RivePanelMessage({required this.message, super.key});

  /// What to say.
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 8),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
