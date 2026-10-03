import 'package:flutter/material.dart';

import '../../../domain/models/preview_hub_route_arguments.dart';
import '../../../domain/models/rive_asset.dart';
import '../../../domain/models/validation_issue.dart';
import '../../../domain/services/asset_metrics_service.dart';
import '../../../domain/services/rive_catalog_service.dart';
import '../../../routing/preview_hub_router.dart';
import '../../../routing/preview_hub_routes.dart';
import '../../../theme/preview_hub_theming.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/rive_view_model.dart';
import '../../widgets/common/collection_header.dart';
import '../../widgets/common/grid_empty_state.dart';
import '../../widgets/common/preview_filter_bar.dart';
import '../../widgets/common/preview_view_button.dart';
import '../../widgets/common/validation_report_sheet.dart';
import '../../widgets/rive/rive_tile.dart';

/// Every bundled and supplied Rive animation, playing in a grid.
class RiveScreen extends StatefulWidget {
  /// Creates the screen, listing [networkRives] after the bundled ones.
  const RiveScreen({this.networkRives = const <String>[], super.key});

  /// Remote animations to list; bundled ones are discovered regardless.
  final List<String> networkRives;

  @override
  State<RiveScreen> createState() => _RiveScreenState();
}

class _RiveScreenState extends State<RiveScreen> {
  /// Room the search field needs, including the gap beneath it.
  static const double _searchHeight = 60;

  /// Gap between tiles.
  static const double _gridSpacing = 14;

  /// The grid's own horizontal padding, both sides together.
  static const double _gridPadding = 32;

  /// Room the tile footer needs: name row plus the facts line.
  static const double _tileFooterHeight = 52;

  /// A `.riv` is binary, and servers label it inconsistently, so anything
  /// other than an HTML page is accepted rather than flagged.
  final AssetMetricsService _metrics = AssetMetricsService(
    contentTypePrefixes: AssetMetricsService.riveContentTypes,
  );
  late final RiveViewModel _viewModel = RiveViewModel(
    catalog: RiveCatalogService(),
    metrics: _metrics,
    networkRives: widget.networkRives,
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

  void _open(RiveAsset asset) {
    Navigator.of(context).push(
      PreviewHubRouter.route(
        PreviewHubRoutes.riveDetail,
        arguments: RiveDetailArguments(
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
      final List<RiveAsset> assets = _viewModel.visibleAssets;
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
              title: const Text(PreviewHubStrings.sectionRiveTitle),
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
                  hintText: PreviewHubStrings.searchRiveHint,
                  resultCount: assets.length,
                  onSearchChanged: _viewModel.search,
                  viewButton: PreviewViewButton(
                    order: _viewModel.sortOrder,
                    onOrderChanged: _viewModel.setSortOrder,
                    columns: _viewModel.columns,
                    columnChoices: RiveViewModel.columnChoices,
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
                  icon: Icons.auto_awesome_motion_rounded,
                  message: PreviewHubStrings.emptyRive,
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
                  itemBuilder: (BuildContext context, int index) => RiveTile(
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
