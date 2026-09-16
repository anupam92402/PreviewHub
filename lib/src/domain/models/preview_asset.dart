import 'package:flutter/foundation.dart';

import 'measurable_asset.dart';

/// Where a previewed asset comes from.
enum AssetSource {
  /// Bundled with the app and listed in the asset manifest.
  bundled('Bundled'),

  /// Fetched over http or https.
  network('Network');

  const AssetSource(this.label);

  /// Name shown on the filter chip.
  final String label;
}

/// Image formats the gallery can list.
enum AssetType {
  /// Scalable Vector Graphics.
  svg('SVG'),

  /// Portable Network Graphics.
  png('PNG'),

  /// Google WebP.
  webp('WEBP'),

  /// JPEG, from either a `.jpg` or `.jpeg` extension.
  jpeg('JPEG'),

  /// Graphics Interchange Format.
  gif('GIF');

  const AssetType(this.label);

  /// Name shown on the filter chip.
  final String label;

  /// Whether Flutter can decode this into a raster image.
  bool get isRaster => this != svg;

  /// Reads the type off the extension at the end of [locator]. Returns null
  /// when the extension is not a supported image format, which is how non-image
  /// entries are kept out of the gallery.
  static AssetType? fromLocator(String locator) {
    final String path = Uri.tryParse(locator)?.path ?? locator;
    final int dot = path.lastIndexOf('.');
    if (dot == -1) {
      return null;
    }
    return switch (path.substring(dot + 1).toLowerCase()) {
      'png' => png,
      'jpg' || 'jpeg' => jpeg,
      'webp' => webp,
      'gif' => gif,
      'svg' => svg,
      _ => null,
    };
  }
}

/// A single asset the gallery can show.
@immutable
class PreviewAsset implements MeasurableAsset {
  /// Creates an asset described by [locator].
  const PreviewAsset({
    required this.name,
    required this.type,
    required this.source,
    required this.locator,
  });

  /// Describes a bundled asset from its manifest [key]. Returns null when [key]
  /// is not a supported image.
  static PreviewAsset? bundled(String key) {
    final AssetType? type = AssetType.fromLocator(key);
    if (type == null) {
      return null;
    }
    return PreviewAsset(
      name: _lastSegment(key),
      type: type,
      source: AssetSource.bundled,
      locator: key,
    );
  }

  /// Describes a remote asset from its [url]. Returns null when the URL does
  /// not end in a supported image extension.
  static PreviewAsset? network(String url) {
    final AssetType? type = AssetType.fromLocator(url);
    if (type == null) {
      return null;
    }
    return PreviewAsset(
      name: _lastSegment(Uri.tryParse(url)?.path ?? url),
      type: type,
      source: AssetSource.network,
      locator: url,
    );
  }

  /// Label shown under the artwork.
  final String name;

  /// Format this asset is encoded in.
  final AssetType type;

  @override
  final AssetSource source;

  /// The manifest key exactly as Flutter exposes it, or the full URL. Never
  /// cleaned up or shortened — this is the string a consumer has to paste into
  /// their own code, so it is shown and copied verbatim.
  @override
  final String locator;

  static String _lastSegment(String path) =>
      path.split('/').where((String part) => part.isNotEmpty).lastOrNull ??
      path;

  @override
  bool operator ==(Object other) =>
      other is PreviewAsset && other.locator == locator;

  @override
  int get hashCode => locator.hashCode;
}
