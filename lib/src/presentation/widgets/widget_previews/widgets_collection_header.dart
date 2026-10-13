import 'package:flutter/material.dart';

import '../../../domain/models/widget_preview.dart';
import '../../../util/preview_hub_strings.dart';
import '../../../util/preview_hub_theme.dart';
import '../../viewmodels/widgets_view_model.dart';
import '../common/preview_filter_bar.dart';
import '../common/preview_search_bar.dart';

/// Search field and section chips at the top of the widget index, drawn in the
/// flexible space of its app bar while the bar is expanded.
class WidgetsCollectionHeader extends StatelessWidget {
  /// Creates the header driving [viewModel].
  const WidgetsCollectionHeader({required this.viewModel, super.key});

  /// State the search field and chips read and update.
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
