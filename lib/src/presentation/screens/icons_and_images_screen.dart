import 'package:flutter/material.dart';

import '../../domain/models/preview_asset.dart';
import '../../domain/models/preview_hub_route_arguments.dart';
import '../../domain/models/validation_issue.dart';
import '../../domain/services/asset_catalog_service.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../preview_hub_strings.dart';
import '../../preview_hub_theme.dart';
import '../routing/preview_hub_router.dart';
import '../routing/preview_hub_routes.dart';
import '../theme/asset_type_style.dart';
import '../theme/preview_hub_theme_controller.dart';
import '../viewmodels/icons_and_images_view_model.dart';
import '../widgets/asset_tile.dart';
import '../widgets/preview_filter_bar.dart';
import '../widgets/preview_search_bar.dart';
import '../widgets/preview_view_button.dart';
import '../widgets/validation_report_sheet.dart';

/// Every bundled and supplied icon or image, searchable and filterable.
class IconsAndImagesScreen extends StatefulWidget {
  /// Creates the screen, listing [networkImages] after the bundled assets.
  const IconsAndImagesScreen({
    this.networkImages = const <String>[],
    super.key,
  });

  /// Remote assets to list; bundled ones are discovered regardless.
  final List<String> networkImages;

  @override
  State<IconsAndImagesScreen> createState() => _IconsAndImagesScreenState();
}

class _IconsAndImagesScreenState extends State<IconsAndImagesScreen> {
  /// Room the search field needs, including the gap beneath it.
  static const double _searchHeight = 60;

  /// Gap between tiles, and the grid's own horizontal padding.
  static const double _gridSpacing = 14;
  static const double _gridPadding = 32;

  /// Room the tile footer needs: name row plus the facts line.
  static const double _tileFooterHeight = 58;

  /// Height of one tile, so its footer survives every column count.
  static double _tileHeight(BuildContext context, int columns) {
    final double available =
        MediaQuery.sizeOf(context).width -
        _gridPadding -
        _gridSpacing * (columns - 1);
    return available / columns + _tileFooterHeight;
  }

  /// Expanded bar height for the search field and both filter rows, scaled
  /// with the text setting so neither is clipped.
  static double _expandedHeight(BuildContext context) =>
      kToolbarHeight +
      MediaQuery.textScalerOf(
        context,
      ).scale(_searchHeight + PreviewFilterBar.heightFor(2));

  final AssetMetricsService _metrics = AssetMetricsService();
  late final IconsAndImagesViewModel _viewModel = IconsAndImagesViewModel(
    catalog: AssetCatalogService(),
    metrics: _metrics,
    networkImages: widget.networkImages,
  );

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _metrics.dispose();
    super.dispose();
  }

  /// Opens the detail route for [asset], taking theming from the route context
  /// rather than a field.
  void _open(PreviewAsset asset) {
    Navigator.of(context).push(
      PreviewHubRouter.route(
        PreviewHubRoutes.assetDetail,
        arguments: AssetDetailArguments(
          asset: asset,
          metrics: _metrics,
          themeController: PreviewHubTheming.controllerOf(context),
        ),
      ),
    );
  }

  /// Builds the grid. The bar keeps one flat colour instead of the Material 3
  /// scrolled-under tint, and the validation report waits until every remote
  /// entry has been contacted. Tiles take a fixed height so the footer survives
  /// every column count, and are keyed by asset so filtering rebinds them
  /// rather than reusing the tile at that index.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (BuildContext context, Widget? child) {
        final List<PreviewAsset> assets = _viewModel.visibleAssets;
        final List<ValidationIssue> issues = _viewModel.issues;

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: _expandedHeight(context),
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                title: const Text(PreviewHubStrings.sectionIconsAndImagesTitle),
                actions: <Widget>[
                  if (_viewModel.isReportReady)
                    IconButton(
                      tooltip: PreviewHubStrings.validationReportTooltip,
                      onPressed: () => ValidationReportSheet.show(
                        context,
                        issues: issues,
                        checkedCount: _viewModel.checkedCount,
                      ),
                      icon: issues.isEmpty
                          ? const Icon(Icons.fact_check_outlined)
                          : Badge.count(
                              count: issues.length,
                              child: const Icon(Icons.menu_book_rounded),
                            ),
                    ),
                  const SizedBox(width: 4),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _Header(
                    viewModel: _viewModel,
                    resultCount: assets.length,
                  ),
                ),
              ),
              if (_viewModel.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (assets.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _viewModel.columns,
                      mainAxisSpacing: _gridSpacing,
                      crossAxisSpacing: _gridSpacing,
                      mainAxisExtent: _tileHeight(context, _viewModel.columns),
                    ),
                    itemCount: assets.length,
                    itemBuilder: (BuildContext context, int index) => AssetTile(
                      key: ValueKey<String>(assets[index].locator),
                      asset: assets[index],
                      metrics: _metrics,
                      onTap: () => _open(assets[index]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Search field and filters, shown only while the app bar is expanded.
class _Header extends StatelessWidget {
  const _Header({required this.viewModel, required this.resultCount});

  final IconsAndImagesViewModel viewModel;
  final int resultCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.paddingOf(context).top,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: PreviewSearchBar(
                    hintText: PreviewHubStrings.searchAssetsHint,
                    resultCount: resultCount,
                    onChanged: viewModel.search,
                  ),
                ),
                const SizedBox(width: 10),
                PreviewViewButton(
                  order: viewModel.sortOrder,
                  onOrderChanged: viewModel.setSortOrder,
                  columns: viewModel.columns,
                  columnChoices: IconsAndImagesViewModel.columnChoices,
                  onColumnsChanged: viewModel.setColumns,
                  isBusy: viewModel.isSorting,
                ),
              ],
            ),
          ),
          PreviewFilterBar(
            groups: <PreviewFilterGroup>[
              PreviewFilterGroup(
                label: PreviewHubStrings.filterSourceLabel,
                filters: <PreviewFilter>[
                  PreviewFilter(
                    label: PreviewHubStrings.filterAll,
                    accent: PreviewHubTheme.filterAllColor,
                    selected: viewModel.isAllSources,
                    onSelected: () => viewModel.selectSource(null),
                  ),
                  for (final AssetSource source in AssetSource.values)
                    PreviewFilter(
                      label: source.label,
                      accent: PreviewHubTheme.filterAllColor,
                      icon: switch (source) {
                        AssetSource.bundled => Icons.folder_outlined,
                        AssetSource.network => Icons.cloud_outlined,
                      },
                      selected: viewModel.selectedSource == source,
                      onSelected: () => viewModel.selectSource(source),
                    ),
                ],
              ),
              PreviewFilterGroup(
                label: PreviewHubStrings.filterTypeLabel,
                filters: <PreviewFilter>[
                  PreviewFilter(
                    label: PreviewHubStrings.filterAll,
                    accent: PreviewHubTheme.filterAllColor,
                    selected: viewModel.isAllTypes,
                    onSelected: viewModel.selectAllTypes,
                  ),
                  for (final AssetType type in viewModel.availableTypes)
                    PreviewFilter(
                      label: type.label,
                      accent: AssetTypeStyle.colorOf(type),
                      selected: viewModel.selectedTypes.contains(type),
                      onSelected: () => viewModel.toggleType(type),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shown when the search and filters exclude everything.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.image_search_rounded,
            size: 34,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            PreviewHubStrings.emptyAssets,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
