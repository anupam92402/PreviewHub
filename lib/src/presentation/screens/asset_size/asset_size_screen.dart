import 'package:flutter/material.dart';

import '../../../domain/models/asset_size_report.dart';
import '../../../domain/models/lottie_asset.dart';
import '../../../domain/models/preview_asset.dart';
import '../../../domain/models/preview_hub_config.dart';
import '../../../domain/models/preview_hub_route_arguments.dart';
import '../../../domain/models/rive_asset.dart';
import '../../../domain/services/asset_metrics_service.dart';
import '../../../domain/services/asset_size_service.dart';
import '../../../routing/preview_hub_router.dart';
import '../../../routing/preview_hub_routes.dart';
import '../../../theme/preview_hub_theme_controller.dart';
import '../../../theme/preview_hub_theming.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/asset_size_view_model.dart';
import '../../widgets/asset_size/asset_size_category_tile.dart';
import '../../widgets/asset_size/asset_size_summary.dart';
import '../../widgets/common/info_note.dart';
import '../../widgets/common/loading_message.dart';
import '../../widgets/common/status_message.dart';

/// What the bundled images, icons, fonts, Lottie and Rive files weigh, as a
/// share of the whole: a donut, and each category's heaviest files. Picking a
/// category on the chart or in the list picks it out in both. A file opens its
/// own preview, and each category opens its whole collection, so a heavy file
/// found here is one tap from being looked at.
class AssetSizeScreen extends StatefulWidget {
  /// Creates the screen; [config] is passed on to the collections it opens.
  const AssetSizeScreen({this.config = const PreviewHubConfig(), super.key});

  /// What the host supplied, handed to any collection opened from here.
  final PreviewHubConfig config;

  @override
  State<AssetSizeScreen> createState() => _AssetSizeScreenState();
}

class _AssetSizeScreenState extends State<AssetSizeScreen> {
  final AssetSizeViewModel _viewModel = AssetSizeViewModel(
    service: AssetSizeService(),
  );

  /// Measurement caches the detail screens share, typed the way each
  /// collection's own grid types them. Made on first use, so a breakdown that
  /// never opens a file creates none.
  AssetMetricsService? _imageMetrics;
  AssetMetricsService? _lottieMetrics;
  AssetMetricsService? _riveMetrics;

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _imageMetrics?.dispose();
    _lottieMetrics?.dispose();
    _riveMetrics?.dispose();
    super.dispose();
  }

  void _push(String name, PreviewHubArguments arguments) => Navigator.of(
    context,
  ).push(PreviewHubRouter.route(name, arguments: arguments));

  /// Opens the preview of [entry]: its detail page, for a font file the fonts
  /// screen on the family it belongs to, and for any other file the Other
  /// screen, since those have no preview of their own.
  void _openFile(AssetSizeEntry entry) {
    final PreviewHubThemeController? theme = PreviewHubTheming.controllerOf(
      context,
    );
    switch (entry.category) {
      case AssetSizeCategory.iconsAndImages:
        final PreviewAsset? asset = PreviewAsset.bundled(entry.locator);
        if (asset != null) {
          _push(
            PreviewHubRoutes.assetDetail,
            AssetDetailArguments(
              asset: asset,
              metrics: _imageMetrics ??= AssetMetricsService(),
              themeController: theme,
            ),
          );
        }
      case AssetSizeCategory.fonts:
        _push(
          PreviewHubRoutes.fonts,
          FontsArguments(
            themeController: theme,
            initialFamily: entry.fontFamily,
          ),
        );
      case AssetSizeCategory.lottie:
        final LottieAsset? asset = LottieAsset.bundled(entry.locator);
        if (asset != null) {
          _push(
            PreviewHubRoutes.lottieDetail,
            LottieDetailArguments(
              asset: asset,
              metrics: _lottieMetrics ??= AssetMetricsService(
                contentTypePrefixes: AssetMetricsService.lottieContentTypes,
              ),
              themeController: theme,
            ),
          );
        }
      case AssetSizeCategory.rive:
        final RiveAsset? asset = RiveAsset.bundled(entry.locator);
        if (asset != null) {
          _push(
            PreviewHubRoutes.riveDetail,
            RiveDetailArguments(
              asset: asset,
              metrics: _riveMetrics ??= AssetMetricsService(
                contentTypePrefixes: AssetMetricsService.riveContentTypes,
              ),
              themeController: theme,
            ),
          );
        }
      case AssetSizeCategory.other:
        _openOther(theme);
    }
  }

  /// Opens the Other screen, which lists every file in the Other slice.
  void _openOther(PreviewHubThemeController? theme) => _push(
    PreviewHubRoutes.otherAssets,
    OtherAssetsArguments(themeController: theme),
  );

  /// Opens the whole collection [category] belongs to.
  void _openCollection(AssetSizeCategory category) {
    final PreviewHubThemeController? theme = PreviewHubTheming.controllerOf(
      context,
    );
    switch (category) {
      case AssetSizeCategory.iconsAndImages:
        _push(
          PreviewHubRoutes.iconsAndImages,
          IconsAndImagesArguments(
            config: widget.config,
            themeController: theme,
          ),
        );
      case AssetSizeCategory.fonts:
        _push(PreviewHubRoutes.fonts, FontsArguments(themeController: theme));
      case AssetSizeCategory.lottie:
        _push(
          PreviewHubRoutes.lottie,
          LottieArguments(config: widget.config, themeController: theme),
        );
      case AssetSizeCategory.rive:
        _push(
          PreviewHubRoutes.rive,
          RiveArguments(config: widget.config, themeController: theme),
        );
      case AssetSizeCategory.other:
        _openOther(theme);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(PreviewHubStrings.sizeTitle),
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    body: ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final AssetSizeReport? report = _viewModel.report;
        if (_viewModel.failed) {
          return const StatusMessage(
            icon: Icons.error_outline_rounded,
            message: PreviewHubStrings.sizeFailed,
          );
        }
        if (report == null) {
          return const LoadingMessage(message: PreviewHubStrings.sizeMeasuring);
        }
        if (report.isEmpty) {
          return const StatusMessage(
            icon: Icons.inventory_2_outlined,
            message: PreviewHubStrings.sizeEmpty,
          );
        }
        final List<AssetSizeCategory> categories = report.presentCategories;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MediaQuery.paddingOf(context).bottom + 28,
          ),
          children: <Widget>[
            AssetSizeSummary(
              report: report,
              selected: _viewModel.selected,
              onSelect: _viewModel.select,
            ),
            const SizedBox(height: 22),
            for (final AssetSizeCategory category in categories)
              AssetSizeCategoryTile(
                report: report,
                category: category,
                expanded: _viewModel.selected == category,
                onTap: () => _viewModel.select(category),
                onOpenFile: _openFile,
                onOpenCollection: () => _openCollection(category),
              ),
            const SizedBox(height: 10),
            const InfoNote(text: PreviewHubStrings.sizeNote),
          ],
        );
      },
    ),
  );
}
