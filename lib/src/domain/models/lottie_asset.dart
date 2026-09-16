import 'package:flutter/foundation.dart';

import 'measurable_asset.dart';
import 'preview_asset.dart';

/// A Lottie animation the gallery can play.
@immutable
class LottieAsset implements MeasurableAsset {
  /// Creates an animation described by [locator].
  const LottieAsset({
    required this.name,
    required this.source,
    required this.locator,
  });

  /// Describes a bundled animation from its manifest [key].
  ///
  /// Returns null for anything that is not JSON. Whether the JSON is really a
  /// Lottie file is only known once it is parsed, so a stray config file shows
  /// up here and fails visibly rather than being guessed at.
  static LottieAsset? bundled(String key) {
    if (!key.toLowerCase().endsWith('.json')) {
      return null;
    }
    return LottieAsset(
      name: _lastSegment(key),
      source: AssetSource.bundled,
      locator: key,
    );
  }

  /// Describes a remote animation from its [url].
  static LottieAsset? network(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return LottieAsset(
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
      path.split('/').where((String part) => part.isNotEmpty).lastOrNull ??
      path;

  @override
  bool operator ==(Object other) =>
      other is LottieAsset && other.locator == locator;

  @override
  int get hashCode => locator.hashCode;
}
