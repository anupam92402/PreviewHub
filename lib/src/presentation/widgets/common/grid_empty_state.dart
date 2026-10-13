import 'package:flutter/material.dart';

/// A glyph and a sentence centred in a collection grid when its search and
/// filters exclude everything.
class GridEmptyState extends StatelessWidget {
  /// Shows [message] under [icon].
  const GridEmptyState({required this.icon, required this.message, super.key});

  /// Glyph of the collection.
  final IconData icon;

  /// Why nothing is shown.
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 34, color: scheme.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
