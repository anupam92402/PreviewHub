/// Names of the screens the gallery navigates between.
///
/// Attached to each route's settings, so a host app's [RouteObserver] sees a
/// meaningful name and can tell gallery routes from its own by the prefix.
class PreviewHubRoutes {
  const PreviewHubRoutes._();

  /// Prefix carried by every route name below.
  static const String previewHub = '/preview-hub';

  /// Index of every component and screen the host registered.
  static const String widgets = '$previewHub/widgets';

  /// Every labelled rendering of one component.
  static const String widgetDetail = '$previewHub/widget-detail';

  /// One registered screen, running full size.
  static const String widgetStage = '$previewHub/widget-stage';

  /// Grid of bundled and remote icons and images.
  static const String iconsAndImages = '$previewHub/icons-and-images';

  /// Every bundled font family.
  static const String fonts = '$previewHub/fonts';

  /// A type tester for the consumer's own words.
  static const String fontSample = '$previewHub/font-sample';

  /// Every bundled and supplied Lottie animation.
  static const String lottie = '$previewHub/lottie';

  /// Everything known about one animation.
  static const String lottieDetail = '$previewHub/lottie-detail';

  /// Every bundled and supplied Rive animation.
  static const String rive = '$previewHub/rive';

  /// Everything known about one Rive animation.
  static const String riveDetail = '$previewHub/rive-detail';

  /// Everything known about one asset.
  static const String assetDetail = '$previewHub/asset-detail';
}
