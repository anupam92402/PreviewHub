import 'package:flutter/material.dart';

import '../../domain/models/preview_hub_route_arguments.dart';
import '../screens/asset_detail_screen.dart';
import '../screens/icons_and_images_screen.dart';
import 'preview_hub_routes.dart';

/// Builds the routes the gallery pushes.
class PreviewHubRouter {
  const PreviewHubRouter._();

  /// Builds the route [settings] describes.
  static Route<void> onGenerateRoute(RouteSettings settings) =>
      MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) => _screenFor(settings),
      );

  /// Route for [name] carrying [arguments], ready for [Navigator.push].
  static Route<void> route(String name, {required Object arguments}) =>
      onGenerateRoute(RouteSettings(name: name, arguments: arguments));

  static Widget _screenFor(RouteSettings settings) {
    switch (settings.name) {
      case PreviewHubRoutes.iconsAndImages:
        final IconsAndImagesArguments args =
            settings.arguments as IconsAndImagesArguments;
        return IconsAndImagesScreen(
          config: args.config,
          themeController: args.themeController,
        );

      case PreviewHubRoutes.assetDetail:
        final AssetDetailArguments args =
            settings.arguments as AssetDetailArguments;
        return AssetDetailScreen(
          asset: args.asset,
          metrics: args.metrics,
          themeController: args.themeController,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
