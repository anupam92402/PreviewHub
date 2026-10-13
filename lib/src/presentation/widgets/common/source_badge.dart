import 'package:flutter/material.dart';

import '../../../domain/models/preview_asset.dart';

/// A small round badge on a grid tile saying whether its file was bundled or
/// fetched from the network.
class SourceBadge extends StatelessWidget {
  /// Creates the badge for [source], drawn in [accent].
  const SourceBadge({
    required this.source,
    required this.accent,
    required this.tooltip,
    super.key,
  });

  /// Where the file came from.
  final AssetSource source;

  /// Colour of the glyph.
  final Color accent;

  /// Text shown on long press.
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(
          switch (source) {
            AssetSource.bundled => Icons.folder_outlined,
            AssetSource.network => Icons.cloud_outlined,
          },
          size: 13,
          color: accent,
        ),
      ),
    );
  }
}
