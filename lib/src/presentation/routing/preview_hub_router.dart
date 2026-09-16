import 'package:flutter/material.dart';

import '../../domain/models/preview_hub_route_arguments.dart';
import '../screens/asset_detail_screen.dart';
import '../screens/font_sample_screen.dart';
import '../screens/fonts_screen.dart';
import '../screens/lottie_detail_screen.dart';
import '../screens/lottie_screen.dart';
import '../screens/rive_detail_screen.dart';
import '../screens/rive_screen.dart';
import '../screens/icons_and_images_screen.dart';
import '../screens/widget_detail_screen.dart';
import '../screens/widget_stage_screen.dart';
import '../screens/widgets_screen.dart';
import '../theme/preview_hub_theme_controller.dart';
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
        return const FontsScreen();

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

      default:
        return const SizedBox.shrink();
    }
  }
}
