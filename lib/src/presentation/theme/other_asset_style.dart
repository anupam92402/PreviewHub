import 'package:flutter/material.dart';

import '../../domain/models/other_asset.dart';

/// Colour and glyph for each kind of file on the Other screen. Kept off the
/// enum so the domain stays free of Material.
class OtherAssetStyle {
  const OtherAssetStyle._();

  /// Colour of [kind]'s heading glyph and file tags.
  static Color colorOf(OtherAssetKind kind) => switch (kind) {
    OtherAssetKind.audio => const Color(0xFF8B5CF6),
    OtherAssetKind.video => const Color(0xFFEF4444),
    OtherAssetKind.json => const Color(0xFF0EA5E9),
    OtherAssetKind.pdf => const Color(0xFFF97316),
    OtherAssetKind.unknown => const Color(0xFF64748B),
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
