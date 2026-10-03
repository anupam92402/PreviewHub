import 'package:flutter/material.dart';

import '../../../domain/models/widget_preview.dart';
import 'widget_thumbnail_stage.dart';

/// The registered widget in a thumbnail, built on its stage and scaled to
/// whatever the tile gives it. A screen keeps its top when the proportions
/// differ, since that is where a screen says what it is; a component is shown
/// whole and centred.
class WidgetThumbnailMiniature extends StatelessWidget {
  /// Creates the miniature of [preview].
  const WidgetThumbnailMiniature({required this.preview, super.key});

  /// Entry being drawn.
  final WidgetPreview preview;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: switch (preview.section) {
      WidgetSection.screens => BoxFit.fitWidth,
      WidgetSection.components => BoxFit.contain,
    },
    alignment: switch (preview.section) {
      WidgetSection.screens => Alignment.topCenter,
      WidgetSection.components => Alignment.center,
    },
    clipBehavior: Clip.hardEdge,
    child: WidgetThumbnailStage(preview: preview),
  );
}
