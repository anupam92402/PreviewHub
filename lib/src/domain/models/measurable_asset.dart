import 'preview_asset.dart';

/// Anything the gallery can measure: a bundled key or a remote URL.
///
/// Images and Lottie files are measured the same way — read the bundle, or ask
/// the server — so the measuring service works on this rather than on either
/// collection's own model.
abstract interface class MeasurableAsset {
  /// The manifest key exactly as Flutter exposes it, or the full URL.
  String get locator;

  /// Whether the asset is bundled or fetched.
  AssetSource get source;
}
