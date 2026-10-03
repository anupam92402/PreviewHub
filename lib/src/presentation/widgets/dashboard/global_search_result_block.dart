import 'package:flutter/material.dart';

import '../../../preview_section.dart';
import '../../../util/preview_hub_colors.dart';
import 'dashboard_section_label.dart';

/// One collection's hits in the landing screen's search results, under its
/// heading.
class GlobalSearchResultBlock extends StatelessWidget {
  /// Creates the block for the collection of [type], headed [title].
  const GlobalSearchResultBlock({
    required this.type,
    required this.title,
    required this.children,
    super.key,
  });

  /// Collection the hits belong to, which sets the heading's glyph.
  final PreviewSectionType type;

  /// Heading of the block.
  final String title;

  /// The hits, stacked in one card.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final PreviewSectionStyle style = PreviewSectionStyle.of(type);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: style.gradient,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  style.icon,
                  size: 13,
                  color: PreviewHubColors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DashboardSectionLabel(label: title.toUpperCase()),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
