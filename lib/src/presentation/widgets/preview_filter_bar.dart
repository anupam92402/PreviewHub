import 'package:flutter/material.dart';

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
  ///
  /// Every chip shares the same neutral background while unselected, so the
  /// row reads as one control; the accent shows in the label until then.
  final Color? accent;

  /// Optional glyph shown before the label.
  final IconData? icon;
}

/// A labelled row of filter chips.
class PreviewFilterGroup {
  /// Creates a row titled [label].
  const PreviewFilterGroup({required this.label, required this.filters});

  /// Title shown to the left of the chips.
  final String label;

  /// Chips in this row, in display order.
  final List<PreviewFilter> filters;
}

/// Stacked rows of filter chips, each row labelled and scrolling on its own.
///
/// Splitting the filters across rows keeps either one short enough to read on
/// a phone without running off the edge.
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
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SizedBox(
                    width: _labelWidth,
                    child: Text(
                      group.label,
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
                    padding: const EdgeInsets.fromLTRB(0, 4, 16, 10),
                    children: <Widget>[
                      for (final PreviewFilter filter in group.filters)
                        _Chip(filter: filter),
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

/// One filter chip: a pill that fills with its colour once selected.
class _Chip extends StatelessWidget {
  const _Chip({required this.filter});

  final PreviewFilter filter;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color? accent = filter.accent;
    final bool on = filter.selected;

    final Color background = on
        ? (accent ?? scheme.primary)
        : scheme.surfaceContainerHigh;
    final Color foreground = on ? Colors.white : accent ?? scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: background,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: filter.onSelected,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (filter.icon != null) ...<Widget>[
                  Icon(filter.icon, size: 15, color: foreground),
                  const SizedBox(width: 8),
                ],
                Text(
                  filter.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
