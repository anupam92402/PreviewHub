import 'package:flutter/material.dart';

import '../domain/models/widget_preview.dart';
import '../presentation/session/preview_history.dart';
import '../preview_hub_strings.dart';
import 'dashboard_section_label.dart';

/// A row of the widget entries opened lately, newest first, so the one being
/// worked on is a tap away. Hidden until something has been opened.
class RecentPreviews extends StatelessWidget {
  /// Creates the row from [history], resolving paths against [previews].
  const RecentPreviews({
    required this.history,
    required this.previews,
    required this.onTap,
    super.key,
  });

  /// Where opened entries are remembered.
  final PreviewHistory history;

  /// Registered entries, to turn remembered paths back into entries.
  final List<WidgetPreview> previews;

  /// Called with the entry tapped.
  final ValueChanged<WidgetPreview> onTap;

  /// The registered entries behind [recents], in the same order. A path whose
  /// entry has since been removed or made unusable is skipped.
  List<WidgetPreview> _resolve(List<String> recents) {
    final Map<String, WidgetPreview> byPath = <String, WidgetPreview>{
      for (final WidgetPreview preview in previews)
        if (preview.isUsable) preview.path: preview,
    };
    return recents
        .map((String path) => byPath[path])
        .nonNulls
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: history.recents,
      builder: (BuildContext context, List<String> recents, Widget? child) {
        final List<WidgetPreview> found = _resolve(recents);
        if (found.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: DashboardSectionLabel(
                  label: PreviewHubStrings.recentLabel,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    for (final WidgetPreview preview in found)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: Icon(switch (preview.section) {
                            WidgetSection.components => Icons.widgets_outlined,
                            WidgetSection.screens => Icons.phone_iphone_rounded,
                          }, size: 16),
                          label: Text(preview.title),
                          onPressed: () => onTap(preview),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
