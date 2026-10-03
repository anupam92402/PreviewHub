import 'package:flutter/material.dart';

import '../../../../util/preview_hub_colors.dart';
import '../preview_filter_bar.dart';

/// One filter chip: a pill that fills with its colour once selected.
class PreviewFilterChip extends StatelessWidget {
  /// Creates the chip for [filter].
  const PreviewFilterChip({required this.filter, super.key});

  /// Label, glyph, colour and state of the chip.
  final PreviewFilter filter;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color? accent = filter.accent;
    final bool on = filter.selected;

    final Color background = on
        ? (accent ?? scheme.primary)
        : scheme.surfaceContainerHigh;
    final Color foreground = on
        ? PreviewHubColors.white
        : accent ?? scheme.onSurface;

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
