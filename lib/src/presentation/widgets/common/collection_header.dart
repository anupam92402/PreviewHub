import 'package:flutter/material.dart';

import 'preview_filter_bar.dart';
import 'preview_search_bar.dart';

/// The search field, view button and filter rows at the top of a collection
/// grid, drawn in the flexible space of its app bar.
class CollectionHeader extends StatelessWidget {
  /// Creates the header searching with [onSearchChanged] and filtering with
  /// [filterGroups].
  const CollectionHeader({
    required this.hintText,
    required this.resultCount,
    required this.onSearchChanged,
    required this.viewButton,
    required this.filterGroups,
    super.key,
  });

  /// Placeholder in the search field.
  final String hintText;

  /// Number of items currently shown, displayed inside the search field.
  final int resultCount;

  /// Called with the query as it is typed.
  final ValueChanged<String> onSearchChanged;

  /// Sort and column control beside the search field.
  final Widget viewButton;

  /// Filter chip rows under the search field.
  final List<PreviewFilterGroup> filterGroups;

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
          child: Row(
            children: <Widget>[
              Expanded(
                child: PreviewSearchBar(
                  hintText: hintText,
                  resultCount: resultCount,
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 10),
              viewButton,
            ],
          ),
        ),
        PreviewFilterBar(groups: filterGroups),
      ],
    ),
  );
}
