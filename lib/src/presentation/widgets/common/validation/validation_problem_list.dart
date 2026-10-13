import 'package:flutter/material.dart';

import '../../../../domain/models/validation_issue.dart';
import '../../../../util/preview_hub_strings.dart';
import '../copy_button.dart';
import 'validation_issue_card.dart';
import 'validation_report_text.dart';

/// The validation report's body when at least one entry could not be used: a
/// summary row with a copy-all button, above one card per failed entry.
class ValidationProblemList extends StatelessWidget {
  /// Creates the list over [issues].
  const ValidationProblemList({required this.issues, super.key});

  /// Entries that failed, in display order.
  final List<ValidationIssue> issues;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: scheme.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.report_problem_outlined,
                size: 21,
                color: scheme.error,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    PreviewHubStrings.validationReportTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    PreviewHubStrings.validationReportSummary(issues.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CopyButton(
              text: issues.reportText,
              tooltip: PreviewHubStrings.copyAll,
              size: 20,
              color: scheme.error,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: issues.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) =>
                ValidationIssueCard(issue: issues[index]),
          ),
        ),
      ],
    );
  }
}
