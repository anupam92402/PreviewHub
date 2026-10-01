import 'package:flutter/material.dart';

import '../domain/models/preview_asset.dart';
import '../domain/models/preview_hub_route_arguments.dart';
import '../domain/models/widget_preview.dart';
import '../presentation/routing/preview_hub_routes.dart';
import '../presentation/theme/preview_hub_theme_controller.dart';
import '../presentation/viewmodels/global_search_view_model.dart';
import '../preview_hub_strings.dart';
import '../preview_section.dart';
import 'dashboard_section_label.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widgets.isNotEmpty)
          _ResultBlock(
            type: PreviewSectionType.widgets,
            title: PreviewHubStrings.sectionWidgetsTitle,
            children: <Widget>[
              for (final WidgetSearchResult hit in widgets)
                _Hit(
                  title: hit.preview.title,
                  subtitle: hit.preview.group,
                  onTap: () => onPreviewTap(hit.preview),
                ),
            ],
          ),
        if (assets.isNotEmpty)
          _ResultBlock(
            type: PreviewSectionType.iconsAndImages,
            title: PreviewHubStrings.sectionIconsAndImagesTitle,
            children: <Widget>[
              for (final AssetSearchResult hit in assets)
                _Hit(
                  title: hit.asset.name,
                  subtitle: '${hit.asset.type.label} · ${hit.asset.locator}',
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
          _ResultBlock(
            type: PreviewSectionType.fonts,
            title: PreviewHubStrings.sectionFontsTitle,
            children: <Widget>[
              for (final FontSearchResult hit in fonts)
                _Hit(
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
          _ResultBlock(
            type: PreviewSectionType.lottie,
            title: PreviewHubStrings.sectionLottieTitle,
            children: <Widget>[
              for (final LottieSearchResult hit in lotties)
                _Hit(
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
          _ResultBlock(
            type: PreviewSectionType.rive,
            title: PreviewHubStrings.sectionRiveTitle,
            children: <Widget>[
              for (final RiveSearchResult hit in rives)
                _Hit(
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
        if (searchVM.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (searchVM.hasNoResults)
          const _NoResults(),
      ],
    );
  }

  static String _sourceLine(AssetSource source, String locator) =>
      '${source.label} · $locator';
}

/// One collection's hits under its heading.
class _ResultBlock extends StatelessWidget {
  const _ResultBlock({
    required this.type,
    required this.title,
    required this.children,
  });

  final PreviewSectionType type;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final PreviewSectionStyle style = PreviewSectionStyle.of(type);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: style.gradient,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(style.icon, size: 13, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DashboardSectionLabel(label: title.toUpperCase()),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

/// One hit.
class _Hit extends StatelessWidget {
  const _Hit({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.fontFamily,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Family to set the title in, for a font hit.
  final String? fontFamily;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: fontFamily == null ? null : TextStyle(fontFamily: fontFamily),
    ),
    subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    onTap: onTap,
  );
}

/// Shown when no collection has anything matching.
class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.search_off_rounded,
            size: 34,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            PreviewHubStrings.searchEverythingEmpty,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
