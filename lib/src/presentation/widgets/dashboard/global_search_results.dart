import 'package:flutter/material.dart';

import '../../../domain/models/preview_asset.dart';
import '../../../domain/models/preview_hub_route_arguments.dart';
import '../../../domain/models/widget_preview.dart';
import '../../../preview_section.dart';
import '../../../routing/preview_hub_routes.dart';
import '../../../theme/preview_hub_theme_controller.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/global_search_view_model.dart';
import 'global_search_hit.dart';
import 'global_search_no_results.dart';
import 'global_search_result_block.dart';

/// What the landing screen's search found, one block per collection, each hit
/// opening the page it names.
class GlobalSearchResults extends StatelessWidget {
  /// Creates the results of [searchVM].
  const GlobalSearchResults({
    required this.searchVM,
    required this.themeController,
    required this.onPreviewTap,
    required this.onPush,
    super.key,
  });

  /// The search being shown.
  final GlobalSearchViewModel searchVM;

  /// Theme every pushed route follows.
  final PreviewHubThemeController themeController;

  /// Opens a widget entry.
  final ValueChanged<WidgetPreview> onPreviewTap;

  /// Pushes a gallery route.
  final void Function(String name, PreviewHubArguments arguments) onPush;

  @override
  Widget build(BuildContext context) {
    final List<WidgetSearchResult> widgets = searchVM.widgets;
    final List<AssetSearchResult> assets = searchVM.assets;
    final List<FontSearchResult> fonts = searchVM.fonts;
    final List<LottieSearchResult> lotties = searchVM.lotties;
    final List<RiveSearchResult> rives = searchVM.rives;
    final List<OtherSearchResult> others = searchVM.others;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widgets.isNotEmpty)
          GlobalSearchResultBlock(
            type: PreviewSectionType.widgets,
            title: PreviewHubStrings.sectionWidgetsTitle,
            children: <Widget>[
              for (final WidgetSearchResult hit in widgets)
                GlobalSearchHit(
                  title: hit.preview.title,
                  subtitle: hit.preview.group,
                  onTap: () => onPreviewTap(hit.preview),
                ),
            ],
          ),
        if (assets.isNotEmpty)
          GlobalSearchResultBlock(
            type: PreviewSectionType.iconsAndImages,
            title: PreviewHubStrings.sectionIconsAndImagesTitle,
            children: <Widget>[
              for (final AssetSearchResult hit in assets)
                GlobalSearchHit(
                  title: hit.asset.name,
                  subtitle: PreviewHubStrings.facts(<String>[
                    hit.asset.type.label,
                    hit.asset.locator,
                  ]),
                  onTap: () => onPush(
                    PreviewHubRoutes.assetDetail,
                    AssetDetailArguments(
                      asset: hit.asset,
                      metrics: searchVM.imageMetrics,
                      themeController: themeController,
                    ),
                  ),
                ),
            ],
          ),
        if (fonts.isNotEmpty)
          GlobalSearchResultBlock(
            type: PreviewSectionType.fonts,
            title: PreviewHubStrings.sectionFontsTitle,
            children: <Widget>[
              for (final FontSearchResult hit in fonts)
                GlobalSearchHit(
                  title: hit.family.name,
                  subtitle: PreviewHubStrings.fontFaceCount(
                    hit.family.faces.length,
                  ),
                  fontFamily: hit.family.manifestKey,
                  onTap: () => onPush(
                    PreviewHubRoutes.fonts,
                    FontsArguments(
                      themeController: themeController,
                      initialFamily: hit.family.manifestKey,
                    ),
                  ),
                ),
            ],
          ),
        if (lotties.isNotEmpty)
          GlobalSearchResultBlock(
            type: PreviewSectionType.lottie,
            title: PreviewHubStrings.sectionLottieTitle,
            children: <Widget>[
              for (final LottieSearchResult hit in lotties)
                GlobalSearchHit(
                  title: hit.asset.name,
                  subtitle: _sourceLine(hit.asset.source, hit.asset.locator),
                  onTap: () => onPush(
                    PreviewHubRoutes.lottieDetail,
                    LottieDetailArguments(
                      asset: hit.asset,
                      metrics: searchVM.lottieMetrics,
                      themeController: themeController,
                    ),
                  ),
                ),
            ],
          ),
        if (rives.isNotEmpty)
          GlobalSearchResultBlock(
            type: PreviewSectionType.rive,
            title: PreviewHubStrings.sectionRiveTitle,
            children: <Widget>[
              for (final RiveSearchResult hit in rives)
                GlobalSearchHit(
                  title: hit.asset.name,
                  subtitle: _sourceLine(hit.asset.source, hit.asset.locator),
                  onTap: () => onPush(
                    PreviewHubRoutes.riveDetail,
                    RiveDetailArguments(
                      asset: hit.asset,
                      metrics: searchVM.riveMetrics,
                      themeController: themeController,
                    ),
                  ),
                ),
            ],
          ),
        if (others.isNotEmpty)
          GlobalSearchResultBlock(
            type: PreviewSectionType.other,
            title: PreviewHubStrings.sectionOtherTitle,
            children: <Widget>[
              for (final OtherSearchResult hit in others)
                GlobalSearchHit(
                  title: hit.location.name,
                  subtitle: PreviewHubStrings.facts(<String>[
                    hit.location.kind.label,
                    hit.location.locator,
                  ]),
                  onTap: () => onPush(
                    PreviewHubRoutes.otherAssets,
                    OtherAssetsArguments(themeController: themeController),
                  ),
                ),
            ],
          ),
        if (searchVM.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (searchVM.hasNoResults)
          const GlobalSearchNoResults(),
      ],
    );
  }

  /// Subtitle for a hit with a [source] and a [locator].
  static String _sourceLine(AssetSource source, String locator) =>
      PreviewHubStrings.facts(<String>[source.label, locator]);
}
