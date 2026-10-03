import 'package:flutter/material.dart';

import '../../../domain/models/lottie_asset.dart';
import '../../../domain/models/preview_hub_route_arguments.dart';
import '../../../domain/models/validation_issue.dart';
import '../../../domain/services/asset_metrics_service.dart';
import '../../../domain/services/lottie_catalog_service.dart';
import '../../../routing/preview_hub_router.dart';
import '../../../routing/preview_hub_routes.dart';
import '../../../theme/preview_hub_theming.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/lottie_view_model.dart';
import '../../widgets/common/collection_header.dart';
import '../../widgets/common/grid_empty_state.dart';
import '../../widgets/common/preview_filter_bar.dart';
import '../../widgets/common/preview_view_button.dart';
import '../../widgets/common/validation_report_sheet.dart';
import '../../widgets/lottie/lottie_tile.dart';

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

  /// Gap between tiles.
  static const double _gridSpacing = 14;

  /// The grid's own horizontal padding, both sides together.
  static const double _gridPadding = 32;

  /// Room the tile footer needs: name row plus the facts line.
  static const double _tileFooterHeight = 52;

  /// A Lottie file is JSON, so a body claiming to be an image is the problem
  /// here rather than the expectation.
  final AssetMetricsService _metrics = AssetMetricsService(
    contentTypePrefixes: AssetMetricsService.lottieContentTypes,
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

  /// Builds the grid. The validation report stays hidden until every remote
  /// entry has been contacted, and tiles are keyed by asset so filtering
  /// rebinds rather than reusing the tile at that index.
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
                background: CollectionHeader(
                  hintText: PreviewHubStrings.searchLottieHint,
                  resultCount: assets.length,
                  onSearchChanged: _viewModel.search,
                  viewButton: PreviewViewButton(
                    order: _viewModel.sortOrder,
                    onOrderChanged: _viewModel.setSortOrder,
                    columns: _viewModel.columns,
                    columnChoices: LottieViewModel.columnChoices,
                    onColumnsChanged: _viewModel.setColumns,
                    isBusy: _viewModel.isSorting,
                  ),
                  filterGroups: <PreviewFilterGroup>[
                    PreviewFilterGroup.sources(
                      selected: _viewModel.selectedSource,
                      onSelected: _viewModel.selectSource,
                    ),
                  ],
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
                child: GridEmptyState(
                  icon: Icons.animation_rounded,
                  message: PreviewHubStrings.emptyLottie,
                ),
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
