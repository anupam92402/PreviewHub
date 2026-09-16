import 'package:flutter/material.dart';

import '../../domain/models/rive_asset.dart';
import '../../domain/models/validation_issue.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/models/preview_hub_route_arguments.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../domain/services/rive_catalog_service.dart';
import '../../preview_hub_strings.dart';
import '../../preview_hub_theme.dart';
import '../routing/preview_hub_router.dart';
import '../routing/preview_hub_routes.dart';
import '../theme/preview_hub_theme_controller.dart';
import '../viewmodels/rive_view_model.dart';
import '../widgets/rive_tile.dart';
import '../widgets/preview_filter_bar.dart';
import '../widgets/preview_search_bar.dart';
import '../widgets/preview_view_button.dart';
import '../widgets/validation_report_sheet.dart';

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

  /// Gap between tiles, and the grid's own horizontal padding.
  static const double _gridSpacing = 14;
  static const double _gridPadding = 32;

  /// Room the tile footer needs: name row plus the facts line.
  static const double _tileFooterHeight = 52;

  /// A `.riv` is binary, and servers label it inconsistently, so anything
  /// other than an HTML page is accepted rather than flagged.
  final AssetMetricsService _metrics = AssetMetricsService(
    contentTypePrefixes: const <String>{'application/', 'binary/'},
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
                background: _RiveHeader(
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
                  itemBuilder: (BuildContext context, int index) => RiveTile(
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
class _RiveHeader extends StatelessWidget {
  const _RiveHeader({required this.viewModel, required this.resultCount});

  final RiveViewModel viewModel;
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
                  hintText: PreviewHubStrings.searchRiveHint,
                  resultCount: resultCount,
                  onChanged: viewModel.search,
                ),
              ),
              const SizedBox(width: 10),
              PreviewViewButton(
                order: viewModel.sortOrder,
                onOrderChanged: viewModel.setSortOrder,
                columns: viewModel.columns,
                columnChoices: RiveViewModel.columnChoices,
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
            Icons.auto_awesome_motion_rounded,
            size: 34,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            PreviewHubStrings.emptyRive,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
