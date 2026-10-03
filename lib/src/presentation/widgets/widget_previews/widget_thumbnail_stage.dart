import 'package:flutter/material.dart';

import '../../../domain/models/widget_preview.dart';
import 'widget_thumbnail_case.dart';

/// The room a thumbnail's widget is laid out in, before any scaling. The
/// widget is held still and out of reach: a thumbnail that ran its animations
/// would keep every visible row ticking, and one that took a tap would
/// navigate from a picture.
class WidgetThumbnailStage extends StatelessWidget {
  /// Creates the stage for [preview].
  const WidgetThumbnailStage({required this.preview, super.key});

  /// Room a screen is laid out in before being scaled down. A fixed size keeps
  /// every thumbnail in the index to the same scale, whatever display the
  /// gallery is running on.
  static const Size _screenStage = Size(390, 844);

  /// The most room a component may take before it is scaled. Both sides are
  /// only capped, never fixed: a component that fills the line it is given
  /// takes the full width and is drawn at the proportions it ships at, while a
  /// checkbox stays checkbox-shaped and is scaled up to fill the tile rather
  /// than sitting as a speck in the middle of a line-wide box.
  static const BoxConstraints _componentStage = BoxConstraints(
    maxWidth: 320,
    maxHeight: 320,
  );

  /// Entry being drawn.
  final WidgetPreview preview;

  /// Builds the stage. A screen gets the fixed screen stage; a component is
  /// bounded on every side, so one written to fill the room it is given lays
  /// out here rather than failing on an unbounded stage, and shrink-wrapped,
  /// so a small one is scaled up instead of lost in it.
  @override
  Widget build(BuildContext context) {
    final Widget content = MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: _screenStage,
        padding: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        textScaler: TextScaler.noScaling,
      ),
      child: TickerMode(
        enabled: false,
        child: IgnorePointer(
          child: ExcludeSemantics(child: WidgetThumbnailCase(preview: preview)),
        ),
      ),
    );

    return switch (preview.section) {
      WidgetSection.screens => SizedBox.fromSize(
        size: _screenStage,
        child: content,
      ),
      WidgetSection.components => ConstrainedBox(
        constraints: _componentStage,
        child: Center(widthFactor: 1, heightFactor: 1, child: content),
      ),
    };
  }
}
