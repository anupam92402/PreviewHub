import 'package:flutter/material.dart';

import '../domain/models/preview_hub_route_arguments.dart';
import '../presentation/screens/asset_size/asset_size_screen.dart';
import '../presentation/screens/fonts/font_sample_screen.dart';
import '../presentation/screens/fonts/fonts_screen.dart';
import '../presentation/screens/icons_and_images/asset_detail_screen.dart';
import '../presentation/screens/icons_and_images/icons_and_images_screen.dart';
import '../presentation/screens/lottie/lottie_detail_screen.dart';
import '../presentation/screens/lottie/lottie_screen.dart';
import '../presentation/screens/other_assets/other_assets_screen.dart';
import '../presentation/screens/rive/rive_detail_screen.dart';
import '../presentation/screens/rive/rive_screen.dart';
import '../presentation/screens/widget_previews/widget_detail_screen.dart';
import '../presentation/screens/widget_previews/widget_stage_screen.dart';
import '../presentation/screens/widget_previews/widgets_screen.dart';
import '../theme/preview_hub_theming.dart';
import 'preview_hub_routes.dart';

/// Builds the routes the gallery pushes.
class PreviewHubRouter {
  const PreviewHubRouter._();

  /// Builds the route [settings] describes.
  static Route<void> onGenerateRoute(RouteSettings settings) =>
      MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => PreviewHubTheming(
          controller:
              (settings.arguments as PreviewHubArguments?)?.themeController,
          child: _screenFor(settings),
        ),
      );

  /// Route for [name] carrying [arguments], ready for [Navigator.push].
  static Route<void> route(String name, {required Object arguments}) =>
      onGenerateRoute(RouteSettings(name: name, arguments: arguments));

  static Widget _screenFor(RouteSettings settings) {
    switch (settings.name) {
      case PreviewHubRoutes.widgets:
        final WidgetsArguments args = settings.arguments as WidgetsArguments;
        return WidgetsScreen(previews: args.config.widgets);

      case PreviewHubRoutes.widgetDetail:
        final WidgetDetailArguments args =
            settings.arguments as WidgetDetailArguments;
        return WidgetDetailScreen(preview: args.preview);

      case PreviewHubRoutes.widgetStage:
        final WidgetStageArguments args =
            settings.arguments as WidgetStageArguments;
        return WidgetStageScreen(preview: args.preview);

      case PreviewHubRoutes.iconsAndImages:
        final IconsAndImagesArguments args =
            settings.arguments as IconsAndImagesArguments;
        return IconsAndImagesScreen(networkImages: args.config.networkImages);

      case PreviewHubRoutes.fonts:
        final FontsArguments args = settings.arguments as FontsArguments;
        return FontsScreen(initialFamily: args.initialFamily);

      case PreviewHubRoutes.fontSample:
        final FontSampleArguments args =
            settings.arguments as FontSampleArguments;
        return FontSampleScreen(families: args.families);

      case PreviewHubRoutes.lottie:
        final LottieArguments args = settings.arguments as LottieArguments;
        return LottieScreen(networkLotties: args.config.networkLotties);

      case PreviewHubRoutes.lottieDetail:
        final LottieDetailArguments args =
            settings.arguments as LottieDetailArguments;
        return LottieDetailScreen(asset: args.asset, metrics: args.metrics);

      case PreviewHubRoutes.rive:
        final RiveArguments args = settings.arguments as RiveArguments;
        return RiveScreen(networkRives: args.config.networkRives);

      case PreviewHubRoutes.riveDetail:
        final RiveDetailArguments args =
            settings.arguments as RiveDetailArguments;
        return RiveDetailScreen(asset: args.asset, metrics: args.metrics);

      case PreviewHubRoutes.assetDetail:
        final AssetDetailArguments args =
            settings.arguments as AssetDetailArguments;
        return AssetDetailScreen(asset: args.asset, metrics: args.metrics);

      case PreviewHubRoutes.otherAssets:
        return const OtherAssetsScreen();

      case PreviewHubRoutes.assetSizes:
        final AssetSizesArguments args =
            settings.arguments as AssetSizesArguments;
        return AssetSizeScreen(config: args.config);

      default:
        return const SizedBox.shrink();
    }
  }
}
