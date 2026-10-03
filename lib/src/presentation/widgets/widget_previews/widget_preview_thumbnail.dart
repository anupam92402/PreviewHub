import 'package:flutter/material.dart';

import '../../../domain/models/widget_preview.dart';
import 'widget_thumbnail_fallback.dart';
import 'widget_thumbnail_miniature.dart';

/// The picture beside an entry's name in the index, so a design system with
/// dozens of entries can be read down rather than opened one at a time. Draws
/// the registered widget itself — the screen, or a component's first case —
/// laid out on a stage and scaled into the tile, unless the host supplied a
/// [WidgetPreview.thumbnail] to stand in for it. What is drawn cannot be
/// touched, cannot animate and cannot be reached by a screen reader: it is a
/// likeness, and the preview is still the only place the widget really runs.
class WidgetPreviewThumbnail extends StatelessWidget {
  /// Creates the thumbnail for [preview].
  const WidgetPreviewThumbnail({required this.preview, super.key});

  /// Size of the tile, which takes the shape of what it holds: a phone for a
  /// screen, a wider and shorter card for a component, which is usually broad
  /// and shallow.
  static Size sizeFor(WidgetSection section) => switch (section) {
    WidgetSection.screens => const Size(40, 64),
    WidgetSection.components => const Size(62, 46),
  };

  /// Entry this thumbnail stands for.
  final WidgetPreview preview;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Size size = sizeFor(preview.section);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Material(
        color: scheme.surfaceContainerHighest,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: RepaintBoundary(
          child: switch (preview.thumbnail) {
            null => WidgetThumbnailMiniature(preview: preview),
            final ImageProvider<Object> image => Image(
              image: image,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stack) =>
                      const WidgetThumbnailFallback(),
            ),
          },
        ),
      ),
    );
  }
}
