import 'package:flutter/material.dart';

import '../../../domain/models/font_family_info.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/fonts_view_model.dart';
import '../common/preview_filter_bar.dart';
import '../common/preview_search_bar.dart';

/// Search field and family chips of the fonts screen, shown while its app bar
/// is expanded.
class FontsHeader extends StatelessWidget {
  /// Creates the header searching and selecting through [viewModel].
  const FontsHeader({required this.viewModel, super.key});

  /// Source of the visible families and target of search and selection.
  final FontsViewModel viewModel;

  /// Offsets the controls clear of the toolbar and status bar, which the
  /// flexible space reaches behind.
  @override
  Widget build(BuildContext context) {
    final List<FontFamilyInfo> families = viewModel.visibleFamilies;

    return Padding(
      padding: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.paddingOf(context).top,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: PreviewSearchBar(
              hintText: PreviewHubStrings.searchFontsHint,
              resultCount: families.length,
              onChanged: viewModel.search,
            ),
          ),
          PreviewFilterBar(
            groups: <PreviewFilterGroup>[
              PreviewFilterGroup(
                label: PreviewHubStrings.fontFamilyFilterLabel,
                filters: <PreviewFilter>[
                  for (final FontFamilyInfo family in families)
                    PreviewFilter(
                      label: family.name,
                      selected: viewModel.selected == family,
                      onSelected: () => viewModel.select(family),
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
