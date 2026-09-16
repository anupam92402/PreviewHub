import 'package:flutter/material.dart';

import '../../domain/models/asset_sort_order.dart';
import '../../preview_hub_strings.dart';
import '../../preview_hub_theme.dart';

/// Chooses how the grid is ordered and how densely it is packed. Shows a
/// spinner while a newly chosen order waits on measurements. The menu carries
/// an explicit minimum width because the default is narrower than the longest
/// sort label.
class PreviewViewButton extends StatelessWidget {
  /// Creates a button showing [order] and [columns] as the current choices.
  const PreviewViewButton({
    required this.order,
    required this.onOrderChanged,
    required this.columns,
    required this.onColumnsChanged,
    required this.columnChoices,
    this.isBusy = false,
    super.key,
  });

  /// Order currently applied.
  final AssetSortOrder order;

  /// Called with the newly chosen order.
  final ValueChanged<AssetSortOrder> onOrderChanged;

  /// Tiles currently placed in one row.
  final int columns;

  /// Called with the newly chosen column count.
  final ValueChanged<int> onColumnsChanged;

  /// Column counts to offer.
  final List<int> columnChoices;

  /// Whether sizes are still being gathered.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool active = order != AssetSortOrder.none;
    const Color accent = PreviewHubTheme.filterAllColor;

    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: active ? accent : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? accent : scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: isBusy
          ? Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: active ? Colors.white : accent,
                ),
              ),
            )
          : PopupMenuButton<Object>(
              tooltip: PreviewHubStrings.sortTooltip,
              onSelected: (Object value) {
                if (value is AssetSortOrder) {
                  onOrderChanged(value);
                } else if (value is int) {
                  onColumnsChanged(value);
                }
              },
              position: PopupMenuPosition.under,
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
              icon: Icon(
                Icons.filter_list_outlined,
                size: 20,
                color: active ? Colors.white : scheme.onSurfaceVariant,
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Object>>[
                for (final AssetSortOrder option in AssetSortOrder.values)
                  PopupMenuItem<Object>(
                    value: option,
                    child: _Choice(
                      icon: _iconFor(option),
                      label: option.label,
                      selected: option == order,
                      accent: accent,
                    ),
                  ),
                const PopupMenuDivider(),
                PopupMenuItem<Object>(
                  enabled: false,
                  height: 32,
                  child: Text(
                    PreviewHubStrings.viewColumnsLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                for (final int count in columnChoices)
                  PopupMenuItem<Object>(
                    value: count,
                    child: _Choice(
                      icon: Icons.grid_view_rounded,
                      label: PreviewHubStrings.viewColumns(count),
                      selected: count == columns,
                      accent: accent,
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Glyph for [order]. Kept off the enum so the domain stays free of Material.
IconData _iconFor(AssetSortOrder order) => switch (order) {
  AssetSortOrder.none => Icons.filter_list_outlined,
  AssetSortOrder.sizeAsc => Icons.arrow_upward_rounded,
  AssetSortOrder.sizeDesc => Icons.arrow_downward_rounded,
};

/// One line in the view menu.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 18,
          color: selected ? accent : scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? accent : null,
            ),
          ),
        ),
      ],
    );
  }
}
