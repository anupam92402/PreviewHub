import 'package:flutter/material.dart';

import '../../preview_hub_strings.dart';

/// What an asset is drawn over on its detail page. Artwork that looks right on
/// the gallery's surface can vanish on the dark background it ships on, and a
/// transparent edge only shows over a checkerboard.
enum PreviewBackdrop {
  /// The gallery's own tinted panel.
  surface(PreviewHubStrings.backdropSurface, Icons.crop_square_rounded),

  /// A checkerboard, showing transparency.
  checker(PreviewHubStrings.backdropChecker, Icons.grid_on_rounded),

  /// Plain white.
  light(PreviewHubStrings.backdropLight, Icons.light_mode_outlined),

  /// Near black.
  dark(PreviewHubStrings.backdropDark, Icons.dark_mode_outlined);

  const PreviewBackdrop(this.label, this.icon);

  /// Name shown in the tooltip.
  final String label;

  /// Glyph on the segment.
  final IconData icon;
}

/// The panel an asset is drawn in, painted per [backdrop].
class PreviewBackdropBox extends StatelessWidget {
  /// Paints [backdrop] behind [child], tinted with [accent] on the surface.
  const PreviewBackdropBox({
    required this.backdrop,
    required this.accent,
    required this.child,
    this.height = 280,
    this.failed = false,
    super.key,
  });

  /// What to paint.
  final PreviewBackdrop backdrop;

  /// Tint of the gallery panel and its border.
  final Color accent;

  /// The artwork.
  final Widget child;

  /// Height of the panel.
  final double height;

  /// Whether the artwork failed, which always shows the tinted panel so the
  /// failure reads as one.
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final PreviewBackdrop effective = failed
        ? PreviewBackdrop.surface
        : backdrop;
    final BorderRadius radius = BorderRadius.circular(20);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: switch (effective) {
          PreviewBackdrop.surface => accent.withValues(
            alpha: failed ? 0.10 : 0.07,
          ),
          PreviewBackdrop.checker => Colors.white,
          PreviewBackdrop.light => Colors.white,
          PreviewBackdrop.dark => const Color(0xFF111318),
        },
        borderRadius: radius,
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: effective == PreviewBackdrop.checker
            ? const _CheckerPainter()
            : null,
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }
}

/// Segments choosing a [PreviewBackdrop].
class PreviewBackdropPicker extends StatelessWidget {
  /// Creates a picker showing [value].
  const PreviewBackdropPicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Backdrop in use.
  final PreviewBackdrop value;

  /// Called with the backdrop picked.
  final ValueChanged<PreviewBackdrop> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<PreviewBackdrop>(
    showSelectedIcon: false,
    style: const ButtonStyle(visualDensity: VisualDensity.compact),
    segments: <ButtonSegment<PreviewBackdrop>>[
      for (final PreviewBackdrop backdrop in PreviewBackdrop.values)
        ButtonSegment<PreviewBackdrop>(
          value: backdrop,
          tooltip: backdrop.label,
          icon: Icon(backdrop.icon, size: 18),
        ),
    ],
    selected: <PreviewBackdrop>{value},
    onSelectionChanged: (Set<PreviewBackdrop> next) => onChanged(next.single),
  );
}

/// Grey and white squares.
class _CheckerPainter extends CustomPainter {
  const _CheckerPainter();

  static const double _cell = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grey = Paint()..color = const Color(0xFFE3E5EA);
    for (double y = 0; y < size.height; y += _cell) {
      for (double x = 0; x < size.width; x += _cell) {
        if (((x + y) / _cell).round().isOdd) {
          canvas.drawRect(Rect.fromLTWH(x, y, _cell, _cell), grey);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter oldDelegate) => false;
}
