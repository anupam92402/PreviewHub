import 'package:flutter/material.dart';

import '../../domain/models/lottie_asset.dart';
import '../../domain/models/validation_issue.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/models/preview_hub_route_arguments.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../domain/services/lottie_catalog_service.dart';
import '../../preview_hub_strings.dart';
import '../../preview_hub_theme.dart';
import '../routing/preview_hub_router.dart';
import '../routing/preview_hub_routes.dart';
import '../theme/preview_hub_theme_controller.dart';
import '../viewmodels/lottie_view_model.dart';
import '../widgets/lottie_tile.dart';
import '../widgets/preview_filter_bar.dart';
import '../widgets/preview_search_bar.dart';
import '../widgets/preview_view_button.dart';
import '../widgets/validation_report_sheet.dart';

/// Every bundled and supplied Lottie animation, playing in a grid.
class LottieScreen extends StatefulWidget {
  /// Creates the screen, listing [networkLotties] after the bundled ones.
  const LottieScreen({this.networkLotties = const <String>[], super.key});

  /// Remote animations to list; bundled ones are discovered regardless.
  final List<String> networkLotties;

  @override
  State<LottieScreen> createState() => _LottieScreenState();
}

class _LottieScreenState extends State<LottieScreen> {
  /// Room the search field needs, including the gap beneath it.
  static const double _searchHeight = 60;

  /// Gap between tiles, and the grid's own horizontal padding.
  static const double _gridSpacing = 14;
  static const double _gridPadding = 32;

  /// Room the tile footer needs: name row plus the facts line.
  static const double _tileFooterHeight = 52;

  /// A Lottie file is JSON, so a body claiming to be an image is the problem
  /// here rather than the expectation.
  final AssetMetricsService _metrics = AssetMetricsService(
    contentTypePrefixes: const <String>{'application/json', 'text/'},
  );
  late final LottieViewModel _viewModel = LottieViewModel(
    catalog: LottieCatalogService(),
    metrics: _metrics,
    networkLotties: widget.networkLotties,
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

  /// Height of one tile, so its footer survives whatever width it gets.
  static double _tileHeight(BuildContext context, int columns) {
    final double available =
        MediaQuery.sizeOf(context).width -
        _gridPadding -
        _gridSpacing * (columns - 1);
    return available / columns + _tileFooterHeight;
  }

  void _open(LottieAsset asset) {
    Navigator.of(context).push(
      PreviewHubRouter.route(
        PreviewHubRoutes.lottieDetail,
        arguments: LottieDetailArguments(
          asset: asset,
          metrics: _metrics,
          themeController: PreviewHubTheming.controllerOf(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _viewModel,
    builder: (BuildContext context, Widget? child) {
      final List<LottieAsset> assets = _viewModel.visibleAssets;
      final List<ValidationIssue> issues = _viewModel.issues;

      return Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight:
                  kToolbarHeight +
                  MediaQuery.textScalerOf(
                    context,
                  ).scale(_searchHeight + PreviewFilterBar.heightFor(1)),
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              title: const Text(PreviewHubStrings.sectionLottieTitle),
              actions: <Widget>[
                // Hidden until every remote entry has been contacted: a report
                // shown earlier would claim all is well before it knows.
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
                background: _LottieHeader(
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
                  itemBuilder: (BuildContext context, int index) => LottieTile(
                    // Keyed by asset so a filter change rebinds rather than
                    // reusing the tile that happened to sit at this index.
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

/// Search field and the source chips, shown while the bar is expanded.
class _LottieHeader extends StatelessWidget {
  const _LottieHeader({required this.viewModel, required this.resultCount});

  final LottieViewModel viewModel;
  final int resultCount;

  @override
  Widget build(BuildContext context) => Padding(
    // The flexible space reaches behind the toolbar and the status bar, so the
    // controls are pushed clear of both.
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
                  hintText: PreviewHubStrings.searchLottieHint,
                  resultCount: resultCount,
                  onChanged: viewModel.search,
                ),
              ),
              const SizedBox(width: 10),
              PreviewViewButton(
                order: viewModel.sortOrder,
                onOrderChanged: viewModel.setSortOrder,
                columns: viewModel.columns,
                columnChoices: LottieViewModel.columnChoices,
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
          ],
        ),
      ],
    ),
  );
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
            Icons.animation_rounded,
            size: 34,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            PreviewHubStrings.emptyLottie,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
