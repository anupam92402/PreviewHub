import 'package:flutter/material.dart';

import '../../domain/models/widget_preview.dart';

/// One labelled rendering: the specification, then the widget it describes.
/// The sample is handed the same unbounded height a real scrolling page would
/// give it. An earlier version capped it, which quietly stretched any widget
/// built around a full-height column: a preview that lays a widget out
/// differently from the app is worse than no preview.
class WidgetCaseCard extends StatelessWidget {
  /// Creates a card for [item].
  const WidgetCaseCard({required this.item, super.key});

  /// Case being drawn.
  final WidgetPreviewCase item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            item.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          ClipRect(child: Builder(builder: item.builder)),
        ],
      ),
    );
  }
}
