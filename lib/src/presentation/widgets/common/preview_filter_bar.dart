import 'package:flutter/material.dart';

import '../../../domain/models/preview_asset.dart';
import '../../../util/preview_hub_strings.dart';
import '../../../util/preview_hub_theme.dart';
import 'filter/preview_filter_chip.dart';

/// One selectable filter in a [PreviewFilterBar].
class PreviewFilter {
  /// Creates a filter labelled [label].
  const PreviewFilter({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.accent,
    this.icon,
  });

  /// Text on the chip.
  final String label;

  /// Whether the chip is currently on.
  final bool selected;

  /// Called when the chip is tapped.
  final VoidCallback onSelected;

  /// Colour the chip fills with once selected, and labels itself in while off.
  /// Every chip shares the same neutral background while unselected, so the row
  /// reads as one control; the accent shows in the label until then.
  final Color? accent;

  /// Optional glyph shown before the label.
  final IconData? icon;
}

/// A row of filter chips, titled or not.
class PreviewFilterGroup {
  /// Creates a row titled [label], or untitled when [label] is null.
  const PreviewFilterGroup({required this.filters, this.label});

  /// The `Source` row: all, then one chip per [AssetSource], with [selected]
  /// on, or `All` when it is null.
  PreviewFilterGroup.sources({
    required AssetSource? selected,
    required ValueChanged<AssetSource?> onSelected,
  }) : this(
         label: PreviewHubStrings.filterSourceLabel,
         filters: <PreviewFilter>[
           PreviewFilter(
             label: PreviewHubStrings.filterAll,
             accent: PreviewHubTheme.filterAllColor,
             selected: selected == null,
             onSelected: () => onSelected(null),
           ),
           for (final AssetSource source in AssetSource.values)
             PreviewFilter(
               label: source.label,
               accent: PreviewHubTheme.filterAllColor,
               icon: switch (source) {
                 AssetSource.bundled => Icons.folder_outlined,
                 AssetSource.network => Icons.cloud_outlined,
               },
               selected: selected == source,
               onSelected: () => onSelected(source),
             ),
         ],
       );

  /// Title shown to the left of the chips. Null on a bar of one row, where a
  /// title only repeats what the chips already say.
  final String? label;

  /// Chips in this row, in display order.
  final List<PreviewFilter> filters;
}

/// Stacked rows of filter chips, each row labelled and scrolling on its own.
/// Splitting the filters across rows keeps either one short enough to read on a
/// phone without running off the edge.
class PreviewFilterBar extends StatelessWidget {
  /// Creates a bar showing each group in [groups], top to bottom.
  const PreviewFilterBar({required this.groups, super.key});

  /// Chip rows, rendered in order.
  final List<PreviewFilterGroup> groups;

  /// Height one row occupies, including the gap beneath it.
  static const double rowHeight = 46;

  /// Width reserved for the row titles, so every row's chips line up.
  static const double _labelWidth = 62;

  /// Height a bar of [rowCount] rows occupies.
  static double heightFor(int rowCount) => rowHeight * rowCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final PreviewFilterGroup group in groups)
          SizedBox(
            height: rowHeight,
            child: Row(
              children: <Widget>[
                if (group.label != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: SizedBox(
                      width: _labelWidth,
                      child: Text(
                        group.label ?? '',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(
                      group.label == null ? 16 : 0,
                      4,
                      16,
                      10,
                    ),
                    children: <Widget>[
                      for (final PreviewFilter filter in group.filters)
                        PreviewFilterChip(filter: filter),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
