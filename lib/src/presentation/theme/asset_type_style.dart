import 'package:flutter/material.dart';

import '../../domain/models/preview_asset.dart';

/// Colour coding that lets a format be recognised at a glance in the grid.
class AssetTypeStyle {
  const AssetTypeStyle._();

  /// Accent bound to [type].
  static Color colorOf(AssetType type) => switch (type) {
    AssetType.png => const Color(0xFF0EA5E9),
    AssetType.jpeg => const Color(0xFFF59E0B),
    AssetType.webp => const Color(0xFF8B5CF6),
    AssetType.gif => const Color(0xFFEC4899),
    AssetType.svg => const Color(0xFF10B981),
  };
}
