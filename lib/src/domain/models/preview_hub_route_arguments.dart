import 'package:flutter/foundation.dart';

import '../../presentation/theme/preview_hub_theme_controller.dart';
import '../services/asset_metrics_service.dart';
import 'font_family_info.dart';
import 'lottie_asset.dart';
import 'rive_asset.dart';
import 'preview_asset.dart';
import 'preview_hub_config.dart';
import 'widget_preview.dart';

/// What every gallery route carries. The theme controller rides on all of them,
/// so the router can theme a route without first working out which screen it is
/// about to build.
@immutable
sealed class PreviewHubArguments {
  /// Creates arguments carrying [themeController].
  const PreviewHubArguments({this.themeController});

  final PreviewHubThemeController? themeController;
}

/// Arguments for the widget index route.
final class WidgetsArguments extends PreviewHubArguments {
  /// Creates arguments carrying [config].
  const WidgetsArguments({
    this.config = const PreviewHubConfig(),
    super.themeController,
  });

  /// Tells the gallery which widgets the host registered.
  final PreviewHubConfig config;
}

/// Arguments for the component detail route.
final class WidgetDetailArguments extends PreviewHubArguments {
  /// Creates arguments describing [preview].
  const WidgetDetailArguments({required this.preview, super.themeController});

  /// Entry being inspected.
  final WidgetPreview preview;
}

/// Arguments for the full-size screen route.
final class WidgetStageArguments extends PreviewHubArguments {
  /// Creates arguments describing [preview].
  const WidgetStageArguments({required this.preview, super.themeController});

  /// Entry being shown.
  final WidgetPreview preview;
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

/// Arguments for the fonts route. Font families are discovered from the
/// manifest, so there is nothing to supply beyond the theme every route
/// carries.
final class FontsArguments extends PreviewHubArguments {
  /// Creates arguments for the fonts route.
  const FontsArguments({super.themeController});
}

/// Arguments for the type tester.
final class FontSampleArguments extends PreviewHubArguments {
  /// Creates arguments offering a choice between [families].
  const FontSampleArguments({required this.families, super.themeController});

  /// Families the tester can set text in.
  final List<FontFamilyInfo> families;
}

/// Arguments for the Lottie route.
final class LottieArguments extends PreviewHubArguments {
  /// Creates arguments carrying [config].
  const LottieArguments({
    this.config = const PreviewHubConfig(),
    super.themeController,
  });

  /// Tells the gallery about animations it cannot discover.
  final PreviewHubConfig config;
}

/// Arguments for the Lottie detail route.
final class LottieDetailArguments extends PreviewHubArguments {
  /// Creates arguments describing [asset].
  const LottieDetailArguments({
    required this.asset,
    required this.metrics,
    super.themeController,
  });

  /// Animation being inspected.
  final LottieAsset asset;

  /// Shared measurement cache, so the detail screen reuses what the grid read.
  final AssetMetricsService metrics;
}

/// Arguments for the Rive route.
final class RiveArguments extends PreviewHubArguments {
  /// Creates arguments carrying [config].
  const RiveArguments({
    this.config = const PreviewHubConfig(),
    super.themeController,
  });

  /// Tells the gallery about animations it cannot discover.
  final PreviewHubConfig config;
}

/// Arguments for the Rive detail route.
final class RiveDetailArguments extends PreviewHubArguments {
  /// Creates arguments describing [asset].
  const RiveDetailArguments({
    required this.asset,
    required this.metrics,
    super.themeController,
  });

  /// Animation being inspected.
  final RiveAsset asset;

  /// Shared measurement cache, so the detail screen reuses what the grid read.
  final AssetMetricsService metrics;
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
