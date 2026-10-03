import 'package:flutter/material.dart';

/// Shown in a thumbnail in place of a widget or image that could not be
/// drawn.
class WidgetThumbnailFallback extends StatelessWidget {
  /// Creates the placeholder.
  const WidgetThumbnailFallback({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Icon(
      Icons.crop_original_rounded,
      size: 16,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
