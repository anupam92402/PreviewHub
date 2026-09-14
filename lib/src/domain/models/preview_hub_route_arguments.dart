import 'package:flutter/foundation.dart';

import '../../presentation/theme/preview_hub_theme_controller.dart';
import '../services/asset_metrics_service.dart';
import 'preview_asset.dart';
import 'preview_hub_config.dart';

/// What every gallery route carries.
///
/// The theme controller rides on all of them, so the router can theme a route
/// without first working out which screen it is about to build.
@immutable
sealed class PreviewHubArguments {
  /// Creates arguments carrying [themeController].
  const PreviewHubArguments({this.themeController});

  final PreviewHubThemeController? themeController;
}

/// Arguments for the icons and images route.
final class IconsAndImagesArguments extends PreviewHubArguments {
  /// Creates arguments carrying [config].
  const IconsAndImagesArguments({
    this.config = const PreviewHubConfig(),
    super.themeController,
  });

  /// Tells the gallery about assets it cannot discover.
  final PreviewHubConfig config;
}

/// Arguments for the asset detail route.
final class AssetDetailArguments extends PreviewHubArguments {
  /// Creates arguments describing [asset].
  const AssetDetailArguments({
    required this.asset,
    required this.metrics,
    super.themeController,
  });

  /// Asset being inspected.
  final PreviewAsset asset;

  /// Shared measurement cache, so the detail screen reuses what the grid read.
  final AssetMetricsService metrics;
}
