import 'package:flutter/material.dart';

import '../../domain/models/widget_preview.dart';

/// One entry in the widget index: a title, a rail and a chevron.
/// Draws no host widget, so the index stays cheap however many entries the
/// gallery holds.
class WidgetIndexTile extends StatelessWidget {
  /// Creates a tile for [preview].
  const WidgetIndexTile({
    required this.preview,
    required this.isLast,
    required this.onTap,
    super.key,
  });

  /// Entry this row stands for.
  final WidgetPreview preview;

  /// Whether this is the final row of its group, which shortens the rail.
  final bool isLast;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 16),
            child: _GroupRail(color: scheme.outlineVariant, stopsShort: isLast),
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        preview.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The hairline tying a group's rows together.
class _GroupRail extends StatelessWidget {
  const _GroupRail({required this.color, required this.stopsShort});

  final Color color;
  final bool stopsShort;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.5,
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: stopsShort ? 0.6 : 1,
        child: ColoredBox(color: color, child: const SizedBox.expand()),
      ),
    );
  }
}
