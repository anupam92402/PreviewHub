import 'package:flutter/material.dart';

import '../../../domain/models/widget_preview.dart';
import 'widget_thumbnail_fallback.dart';

/// The screen, or a component's first case, as drawn inside a thumbnail. It
/// builds in its own element and stands in a placeholder if the builder
/// refuses to run here: a widget that needs scaffolding the index cannot give
/// it loses its thumbnail, never the index.
class WidgetThumbnailCase extends StatelessWidget {
  /// Creates the case drawn for [preview].
  const WidgetThumbnailCase({required this.preview, super.key});

  /// Entry whose first usable case is built.
  final WidgetPreview preview;

  @override
  Widget build(BuildContext context) {
    try {
      return preview.usableCases.first.builder(context);
    } on Object catch (_) {
      return const WidgetThumbnailFallback();
    }
  }
}
