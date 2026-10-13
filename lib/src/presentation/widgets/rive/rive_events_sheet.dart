import 'package:flutter/material.dart';

import '../../../domain/models/rive_event_record.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/rive_event_log.dart';
import 'rive_event_row.dart';

/// Bottom sheet listing every event in [log], newest first, updating live as
/// more arrive. Clearing the list closes the sheet.
class RiveEventsSheet extends StatelessWidget {
  /// Creates the sheet over [log].
  const RiveEventsSheet({required this.log, super.key});

  /// Events shown.
  final RiveEventLog log;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: log,
      builder: (BuildContext context, Widget? child) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 4),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      PreviewHubStrings.facts(<String>[
                        PreviewHubStrings.riveEvents,
                        '${log.count}',
                      ]),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      log.clear();
                      Navigator.of(context).maybePop();
                    },
                    child: const Text(PreviewHubStrings.riveEventsClear),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 12, 16),
                children: <Widget>[
                  for (final RiveEventRecord record in log.events)
                    RiveEventRow(record: record),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
