import 'package:flutter/material.dart';

import '../../domain/models/widget_preview.dart';

/// The picture beside an entry's name in the index, so a design system with
/// dozens of entries can be read down rather than opened one at a time.
///
/// Draws the registered widget itself — the screen, or a component's first
/// case — laid out on a stage and scaled into the tile, unless the host
/// supplied a [WidgetPreview.thumbnail] to stand in for it. What is drawn
/// cannot be touched, cannot animate and cannot be reached by a screen reader:
/// it is a likeness, and the preview is still the only place the widget really
/// runs.
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
            null => _Miniature(preview: preview),
            final ImageProvider<Object> image => Image(
              image: image,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stack) =>
                      const _ThumbnailFallback(),
            ),
          },
        ),
      ),
    );
  }
}

/// The widget, built on its stage and scaled to whatever the tile gives it.
/// A screen keeps its top when the proportions differ, since that is where a
/// screen says what it is; a component is shown whole and centred.
class _Miniature extends StatelessWidget {
  const _Miniature({required this.preview});

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
    child: _Stage(preview: preview),
  );
}

/// The room the widget is laid out in, before any scaling.
class _Stage extends StatelessWidget {
  const _Stage({required this.preview});

  final WidgetPreview preview;

  @override
  Widget build(BuildContext context) {
    final Widget content = MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: WidgetPreviewThumbnail._screenStage,
        padding: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        textScaler: TextScaler.noScaling,
      ),
      // Held still and out of reach: a thumbnail that ran its animations would
      // keep every visible row ticking, and one that took a tap would navigate
      // from a picture.
      child: TickerMode(
        enabled: false,
        child: IgnorePointer(
          child: ExcludeSemantics(child: Builder(builder: _buildCase)),
        ),
      ),
    );

    return switch (preview.section) {
      WidgetSection.screens => SizedBox.fromSize(
        size: WidgetPreviewThumbnail._screenStage,
        child: content,
      ),
      // Bounded on every side, so a component written to fill the room it is
      // given lays out here rather than failing on an unbounded stage, and
      // shrink-wrapped, so a small one is scaled up instead of lost in it.
      WidgetSection.components => ConstrainedBox(
        constraints: WidgetPreviewThumbnail._componentStage,
        child: Center(widthFactor: 1, heightFactor: 1, child: content),
      ),
    };
  }

  /// Builds the screen, or a component's first case, standing in a placeholder
  /// if the builder refuses to run here. A widget that needs scaffolding the
  /// index cannot give it loses its thumbnail, never the index.
  Widget _buildCase(BuildContext context) {
    try {
      return preview.usableCases.first.builder(context);
    } on Object catch (_) {
      return const _ThumbnailFallback();
    }
  }
}

/// Shown in place of a widget that could not be drawn.
class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) => Center(
    child: Icon(
      Icons.crop_original_rounded,
      size: 16,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
