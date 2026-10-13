import 'package:flutter/material.dart';

import '../../../domain/models/preview_hub_config.dart';
import '../../../domain/models/preview_hub_route_arguments.dart';
import '../../../domain/models/widget_preview.dart';
import '../../../preview_section.dart';
import '../../../routing/preview_hub_router.dart';
import '../../../routing/preview_hub_routes.dart';
import '../../../session/preview_history.dart';
import '../../../theme/preview_hub_theme_controller.dart';
import '../../../theme/preview_hub_theming.dart';
import '../../viewmodels/global_search_view_model.dart';
import '../../widgets/dashboard/dashboard_body.dart';

/// Landing screen listing every previewable collection.
class PreviewHubDashboard extends StatefulWidget {
  /// Creates the landing screen.
  const PreviewHubDashboard({
    this.config = const PreviewHubConfig(),
    super.key,
  });

  /// Tells the gallery about assets it cannot discover, such as remote URLs.
  final PreviewHubConfig config;

  @override
  State<PreviewHubDashboard> createState() => _PreviewHubDashboardState();
}

class _PreviewHubDashboardState extends State<PreviewHubDashboard> {
  final PreviewHubThemeController _themeController =
      PreviewHubThemeController();
  late final GlobalSearchViewModel _search = GlobalSearchViewModel(
    config: widget.config,
  );

  @override
  void dispose() {
    _search.dispose();
    _themeController.dispose();
    super.dispose();
  }

  /// Opens the collection behind [section], for the ones that exist yet.
  /// Switching over the type rather than testing one case means a collection
  /// added later will not silently fall through to doing nothing.
  void _openSection(PreviewSection section) {
    switch (section.type) {
      case PreviewSectionType.iconsAndImages:
        _push(
          PreviewHubRoutes.iconsAndImages,
          IconsAndImagesArguments(
            config: widget.config,
            themeController: _themeController,
          ),
        );

      case PreviewSectionType.fonts:
        _push(
          PreviewHubRoutes.fonts,
          FontsArguments(themeController: _themeController),
        );

      case PreviewSectionType.lottie:
        _push(
          PreviewHubRoutes.lottie,
          LottieArguments(
            config: widget.config,
            themeController: _themeController,
          ),
        );

      case PreviewSectionType.rive:
        _push(
          PreviewHubRoutes.rive,
          RiveArguments(
            config: widget.config,
            themeController: _themeController,
          ),
        );

      case PreviewSectionType.widgets:
        _push(
          PreviewHubRoutes.widgets,
          WidgetsArguments(
            config: widget.config,
            themeController: _themeController,
          ),
        );

      case PreviewSectionType.other:
        _push(
          PreviewHubRoutes.otherAssets,
          OtherAssetsArguments(themeController: _themeController),
        );
    }
  }

  /// Opens [preview] on its own page and remembers it as recently opened.
  void _openPreview(WidgetPreview preview) {
    PreviewHistory.instance.recordOpened(preview.path);
    switch (preview.section) {
      case WidgetSection.components:
        _push(
          PreviewHubRoutes.widgetDetail,
          WidgetDetailArguments(
            preview: preview,
            themeController: _themeController,
          ),
        );
      case WidgetSection.screens:
        _push(
          PreviewHubRoutes.widgetStage,
          WidgetStageArguments(
            preview: preview,
            themeController: _themeController,
          ),
        );
    }
  }

  /// Pushes the gallery route [name] with [arguments].
  void _push(String name, PreviewHubArguments arguments) => Navigator.of(
    context,
  ).push(PreviewHubRouter.route(name, arguments: arguments));

  @override
  Widget build(BuildContext context) {
    return PreviewHubTheming(
      controller: _themeController,
      child: DashboardBody(
        themeController: _themeController,
        search: _search,
        config: widget.config,
        onSectionTap: _openSection,
        onPreviewTap: _openPreview,
        onPush: _push,
      ),
    );
  }
}
