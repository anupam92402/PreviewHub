import 'package:flutter/material.dart';

import '../domain/models/other_asset.dart';
import '../util/preview_hub_colors.dart';

/// Colour and glyph for each kind of file on the Other screen. Kept off the
/// enum so the domain stays free of Material.
class OtherAssetStyle {
  const OtherAssetStyle._();

  /// Colour of [kind]'s heading glyph and file tags.
  static Color colorOf(OtherAssetKind kind) => switch (kind) {
    OtherAssetKind.audio => PreviewHubColors.violet,
    OtherAssetKind.video => PreviewHubColors.red,
    OtherAssetKind.json => PreviewHubColors.sky,
    OtherAssetKind.pdf => PreviewHubColors.orange,
    OtherAssetKind.unknown => PreviewHubColors.slate,
  };

  /// Glyph beside [kind]'s heading and files.
  static IconData iconOf(OtherAssetKind kind) => switch (kind) {
    OtherAssetKind.audio => Icons.audiotrack_rounded,
    OtherAssetKind.video => Icons.movie_rounded,
    OtherAssetKind.json => Icons.data_object_rounded,
    OtherAssetKind.pdf => Icons.picture_as_pdf_rounded,
    OtherAssetKind.unknown => Icons.insert_drive_file_outlined,
  };
}
