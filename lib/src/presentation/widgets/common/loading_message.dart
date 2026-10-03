import 'package:flutter/material.dart';

/// A full-size progress ring with a sentence under it, filling a screen while
/// its content loads.
class LoadingMessage extends StatelessWidget {
  /// Shows [message] under the progress ring.
  const LoadingMessage({required this.message, super.key});

  /// What is being loaded.
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const CircularProgressIndicator(),
        const SizedBox(height: 14),
        Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}
