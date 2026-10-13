import 'package:flutter/material.dart';

import '../../../../domain/models/validation_issue.dart';
import '../copy_button.dart';
import 'validation_report_text.dart';

/// A single failed entry, boxed so a long URL stays readable, with a button
/// copying the URL and why it failed.
class ValidationIssueCard extends StatelessWidget {
  /// Creates the card for [issue].
  const ValidationIssueCard({required this.issue, super.key});

  /// The failed entry and its reason.
  final ValidationIssue issue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Material(
      color: scheme.error.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.error.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SelectableText(
                    issue.entry,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    issue.description,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ],
              ),
            ),
            CopyButton(text: issue.reportText, color: scheme.error),
          ],
        ),
      ),
    );
  }
}
