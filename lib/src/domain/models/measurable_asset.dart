import 'preview_asset.dart';

/// Anything the gallery can measure: a bundled key or a remote URL. Every kind
/// is measured the same way, so the measuring service works on this rather than
/// on each collection's own model.
abstract interface class MeasurableAsset {
  /// The manifest key exactly as Flutter exposes it, or the full URL.
  String get locator;

  /// Whether the asset is bundled or fetched.
  AssetSource get source;
}
