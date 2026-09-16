import 'package:flutter/foundation.dart';

import 'measurable_asset.dart';
import 'preview_asset.dart';

/// A Rive animation the gallery can play.
@immutable
class RiveAsset implements MeasurableAsset {
  /// Creates an animation described by [locator].
  const RiveAsset({
    required this.name,
    required this.source,
    required this.locator,
  });

  /// Describes a bundled animation from its manifest [key].
  static RiveAsset? bundled(String key) {
    if (!key.toLowerCase().endsWith('.riv')) {
      return null;
    }
    return RiveAsset(
      name: _lastSegment(key),
      source: AssetSource.bundled,
      locator: key,
    );
  }

  /// Describes a remote animation from its [url].
  static RiveAsset? network(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return RiveAsset(
      name: _lastSegment(uri.path.isEmpty ? url : uri.path),
      source: AssetSource.network,
      locator: url,
    );
  }

  /// File name, used as the display label.
  final String name;

  @override
  final AssetSource source;

  @override
  final String locator;

  static String _lastSegment(String path) =>
      path.split('/').where((String part) => part.isNotEmpty).lastOrNull ?? path;

  @override
  bool operator ==(Object other) => other is RiveAsset && other.locator == locator;

  @override
  int get hashCode => locator.hashCode;
}
