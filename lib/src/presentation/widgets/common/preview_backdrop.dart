import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';

export 'backdrop/preview_backdrop_box.dart';
export 'backdrop/preview_backdrop_picker.dart';

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
