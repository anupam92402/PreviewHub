import 'package:flutter/material.dart';

import '../domain/models/preview_asset.dart';
import '../util/preview_hub_colors.dart';

/// Colour coding that lets a format be recognised at a glance in the grid.
class AssetTypeStyle {
  const AssetTypeStyle._();

  /// Accent bound to [type].
  static Color colorOf(AssetType type) => switch (type) {
    AssetType.png => PreviewHubColors.sky,
    AssetType.jpeg => PreviewHubColors.amber,
    AssetType.webp => PreviewHubColors.violet,
    AssetType.gif => PreviewHubColors.pink,
    AssetType.svg => PreviewHubColors.emerald,
  };
}
