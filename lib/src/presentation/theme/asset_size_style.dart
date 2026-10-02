import 'package:flutter/material.dart';

import '../../domain/models/asset_size_report.dart';
import '../../preview_section.dart';

/// Colour and glyph for each slice of the size breakdown, taken from the
/// landing screen's card for the same collection so the two always match.
/// Kept off the enum so the domain stays free of Material.
class AssetSizeStyle {
  const AssetSizeStyle._();

  /// Colour of [category]'s slice, bar and dot.
  static Color colorOf(AssetSizeCategory category) =>
      PreviewSectionStyle.of(_sectionOf(category)).accentStart;

  /// Glyph beside [category]'s name.
  static IconData iconOf(AssetSizeCategory category) =>
      PreviewSectionStyle.of(_sectionOf(category)).icon;

  static PreviewSectionType _sectionOf(AssetSizeCategory category) =>
      switch (category) {
        AssetSizeCategory.iconsAndImages => PreviewSectionType.iconsAndImages,
        AssetSizeCategory.fonts => PreviewSectionType.fonts,
        AssetSizeCategory.lottie => PreviewSectionType.lottie,
        AssetSizeCategory.rive => PreviewSectionType.rive,
        AssetSizeCategory.other => PreviewSectionType.other,
      };
}
