/// Names of the screens the gallery navigates between.
///
/// Attached to each route's settings, so a host app's [RouteObserver] sees a
/// meaningful name and can tell gallery routes from its own by the prefix.
class PreviewHubRoutes {
  const PreviewHubRoutes._();

  /// Prefix carried by every route name below.
  static const String prefix = '/preview-hub';

  /// Grid of bundled and remote icons and images.
  static const String iconsAndImages = '$prefix/icons-and-images';

  /// Everything known about one asset.
  static const String assetDetail = '$prefix/asset-detail';
}
