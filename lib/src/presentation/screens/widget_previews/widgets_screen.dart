import 'package:flutter/material.dart';

import '../../../domain/models/preview_hub_route_arguments.dart';
import '../../../domain/models/widget_preview.dart';
import '../../../domain/services/widget_catalog_service.dart';
import '../../../routing/preview_hub_router.dart';
import '../../../routing/preview_hub_routes.dart';
import '../../../session/preview_history.dart';
import '../../../theme/preview_hub_theme_controller.dart';
import '../../../theme/preview_hub_theming.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/widgets_view_model.dart';
import '../../widgets/common/preview_filter_bar.dart';
import '../../widgets/common/status_message.dart';
import '../../widgets/widget_previews/widget_group_header.dart';
import '../../widgets/widget_previews/widget_index_tile.dart';
import '../../widgets/widget_previews/widgets_collection_header.dart';

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

  /// Opens [preview] and remembers it as recently opened: a component lists
  /// its cases, a screen takes the display.
  void _open(WidgetPreview preview) {
    PreviewHistory.instance.recordOpened(preview.path);
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
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _viewModel,
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
                background: WidgetsCollectionHeader(viewModel: _viewModel),
              ),
            ),
            if (rows.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: StatusMessage(
                  icon: Icons.widgets_outlined,
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

  /// Group the heading stands for.
  final WidgetPreviewGroup group;

  /// Whether the group's entries are folded away.
  final bool collapsed;
}

/// One entry under a heading.
final class _EntryRow extends _IndexRow {
  const _EntryRow({required this.preview, required this.isLast});

  /// Entry the row stands for.
  final WidgetPreview preview;

  /// Whether this is the final entry of its group.
  final bool isLast;
}
