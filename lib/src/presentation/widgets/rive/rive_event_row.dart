import 'package:flutter/material.dart';

import '../../../domain/models/rive_event_record.dart';
import '../../../util/preview_hub_strings.dart';

/// One reported Rive event: its name and kind, when it fired, and whatever it
/// carries, such as a URL or custom properties.
class RiveEventRow extends StatelessWidget {
  /// Creates the row for [record].
  const RiveEventRow({required this.record, super.key});

  /// Event shown.
  final RiveEventRecord record;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String? detail = record.detail;
    final TextStyle? muted = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 8, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  record.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                PreviewHubStrings.facts(<String>[
                  switch (record.kind) {
                    RiveEventKind.general => PreviewHubStrings.riveEventGeneral,
                    RiveEventKind.openUrl => PreviewHubStrings.riveEventOpenUrl,
                    RiveEventKind.audio => PreviewHubStrings.riveEventAudio,
                  },
                  PreviewHubStrings.riveEventTime(record.elapsed),
                ]),
                style: muted,
              ),
            ],
          ),
          if (detail != null && detail.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(detail, style: muted),
            ),
          if (record.properties.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                PreviewHubStrings.facts(record.properties),
                style: muted,
              ),
            ),
        ],
      ),
    );
  }
}
