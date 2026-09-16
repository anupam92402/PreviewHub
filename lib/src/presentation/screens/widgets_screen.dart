import 'package:flutter/material.dart';

import '../../domain/models/preview_hub_route_arguments.dart';
import '../../domain/models/widget_preview.dart';
import '../../domain/services/widget_catalog_service.dart';
import '../../preview_hub_strings.dart';
import '../../preview_hub_theme.dart';
import '../routing/preview_hub_router.dart';
import '../routing/preview_hub_routes.dart';
import '../theme/preview_hub_theme_controller.dart';
import '../viewmodels/widgets_view_model.dart';
import '../widgets/preview_filter_bar.dart';
import '../widgets/preview_search_bar.dart';
import '../widgets/widget_group_header.dart';
import '../widgets/widget_index_tile.dart';

/// Index of every component and screen the host registered. Metadata only: a
/// widget that throws can take down its own preview, never this screen.
class WidgetsScreen extends StatefulWidget {
  /// Creates the index over [previews].
  const WidgetsScreen({this.previews = const <WidgetPreview>[], super.key});

  /// Entries supplied through the gallery's configuration.
  final List<WidgetPreview> previews;

  @override
  State<WidgetsScreen> createState() => _WidgetsScreenState();
}

class _WidgetsScreenState extends State<WidgetsScreen> {
  /// Room the search field needs, including the gap beneath it.
  static const double _searchHeight = 60;

  late final WidgetsViewModel _viewModel = WidgetsViewModel(
    catalog: const WidgetCatalogService(),
    previews: widget.previews,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Opens [preview]: a component lists its cases, a screen takes the display.
  void _open(WidgetPreview preview) {
    final PreviewHubThemeController? controller =
        PreviewHubTheming.controllerOf(context);

    Navigator.of(context).push(switch (preview.section) {
      WidgetSection.components => PreviewHubRouter.route(
        PreviewHubRoutes.widgetDetail,
        arguments: WidgetDetailArguments(
          preview: preview,
          themeController: controller,
        ),
      ),
      WidgetSection.screens => PreviewHubRouter.route(
        PreviewHubRoutes.widgetStage,
        arguments: WidgetStageArguments(
          preview: preview,
          themeController: controller,
        ),
      ),
    });
  }

  /// Flattens the groups into the rows the sliver list draws.
  List<_IndexRow> _rows() {
    final List<_IndexRow> rows = <_IndexRow>[];

    for (final WidgetPreviewGroup group in _viewModel.groups) {
      final bool collapsed = _viewModel.isCollapsed(group.key);
      rows.add(_GroupRow(group: group, collapsed: collapsed));

      if (collapsed) {
        continue;
      }
      for (final WidgetPreview preview in group.previews) {
        rows.add(
          _EntryRow(preview: preview, isLast: preview == group.previews.last),
        );
      }
    }

    return rows;
  }

  /// Builds the index. A host that registered nothing gets guidance, a search
  /// that matched nothing does not, and the section label shows only while
  /// both sections are listed together.
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _viewModel,
    builder: (BuildContext context, Widget? child) {
      final List<_IndexRow> rows = _rows();

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
              title: const Text(PreviewHubStrings.sectionWidgetsTitle),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _WidgetsHeader(viewModel: _viewModel),
              ),
            ),
            if (rows.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  message: widget.previews.isEmpty
                      ? PreviewHubStrings.emptyWidgetsUnregistered
                      : PreviewHubStrings.emptyWidgets,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.paddingOf(context).bottom + 28,
                ),
                sliver: SliverList.builder(
                  itemCount: rows.length,
                  itemBuilder: (BuildContext context, int index) =>
                      switch (rows[index]) {
                        final _GroupRow row => WidgetGroupHeader(
                          name: row.group.name,
                          count: row.group.count,
                          collapsed: row.collapsed,
                          section: _viewModel.isAllSections
                              ? row.group.section
                              : null,
                          onTap: () => _viewModel.toggleGroup(row.group.key),
                        ),
                        final _EntryRow row => WidgetIndexTile(
                          preview: row.preview,
                          isLast: row.isLast,
                          onTap: () => _open(row.preview),
                        ),
                      },
                ),
              ),
          ],
        ),
      );
    },
  );
}

/// One line of the index: either a heading or an entry beneath it.
sealed class _IndexRow {
  const _IndexRow();
}

/// A group heading, with the count and the fold control.
final class _GroupRow extends _IndexRow {
  const _GroupRow({required this.group, required this.collapsed});

  final WidgetPreviewGroup group;
  final bool collapsed;
}

/// One entry under a heading.
final class _EntryRow extends _IndexRow {
  const _EntryRow({required this.preview, required this.isLast});

  final WidgetPreview preview;
  final bool isLast;
}

/// Search field and the section chips, shown while the bar is expanded.
class _WidgetsHeader extends StatelessWidget {
  const _WidgetsHeader({required this.viewModel});

  final WidgetsViewModel viewModel;

  /// Offsets the controls clear of the toolbar and status bar, which the
  /// flexible space reaches behind.
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      top: kToolbarHeight + MediaQuery.paddingOf(context).top,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: PreviewSearchBar(
            hintText: PreviewHubStrings.searchWidgetsHint,
            resultCount: viewModel.resultCount,
            onChanged: viewModel.search,
          ),
        ),
        PreviewFilterBar(
          groups: <PreviewFilterGroup>[
            PreviewFilterGroup(
              filters: <PreviewFilter>[
                PreviewFilter(
                  label: PreviewHubStrings.filterAll,
                  accent: PreviewHubTheme.filterAllColor,
                  selected: viewModel.isAllSections,
                  onSelected: () => viewModel.selectSection(null),
                ),
                for (final WidgetSection section in WidgetSection.values)
                  PreviewFilter(
                    label: section.label,
                    accent: PreviewHubTheme.filterAllColor,
                    icon: switch (section) {
                      WidgetSection.components => Icons.widgets_outlined,
                      WidgetSection.screens => Icons.phone_iphone_rounded,
                    },
                    selected: viewModel.selectedSection == section,
                    onSelected: () => viewModel.selectSection(section),
                  ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

/// Shown when the search and chips exclude everything.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.widgets_outlined,
              size: 34,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
