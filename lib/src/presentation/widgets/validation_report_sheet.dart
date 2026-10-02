import 'package:flutter/material.dart';

import '../../domain/models/validation_issue.dart';
import '../../preview_hub_strings.dart';
import 'copy_button.dart';

/// Lists every entry that failed validation, so none is dropped silently.
/// Only shown once the check has finished, so the all-clear means the entries
/// were contacted and came back fine rather than simply not looked at yet.
class ValidationReportSheet extends StatelessWidget {
  /// Creates a report over [issues], covering [checkedCount] entries.
  const ValidationReportSheet({
    required this.issues,
    required this.checkedCount,
    super.key,
  });

  /// Problems to show; an empty list renders the all-clear.
  final List<ValidationIssue> issues;

  /// How many entries were checked to produce this report.
  final int checkedCount;

  /// Opens the report as a modal sheet.
  static Future<void> show(
    BuildContext context, {
    required List<ValidationIssue> issues,
    required int checkedCount,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) =>
          ValidationReportSheet(issues: issues, checkedCount: checkedCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: issues.isEmpty
                ? _AllClear(checkedCount: checkedCount)
                : _Problems(issues: issues, checkedCount: checkedCount),
          ),
        ),
      ),
    );
  }
}

/// Shown when every entry came back fine.
class _AllClear extends StatelessWidget {
  const _AllClear({required this.checkedCount});

  final int checkedCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    const Color good = Color(0xFF10B981);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 12),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: good.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            size: 30,
            color: good,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          PreviewHubStrings.validationReportEmpty,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          PreviewHubStrings.validationReportChecked(checkedCount),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Shown when at least one entry could not be used.
class _Problems extends StatelessWidget {
  const _Problems({required this.issues, required this.checkedCount});

  final List<ValidationIssue> issues;
  final int checkedCount;

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
              text: _reportText(issues),
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
                _IssueCard(issue: issues[index]),
          ),
        ),
      ],
    );
  }
}

/// The whole report as plain text, ready to paste into a ticket or a chat.
String _reportText(List<ValidationIssue> issues) =>
    issues.map(_issueText).join('\n\n');

/// One entry and its reason, on two lines.
String _issueText(ValidationIssue issue) =>
    '${issue.entry}\n  ${issue.description}';

/// A single failed entry, boxed so a long URL stays readable, with a button
/// copying the URL and why it failed.
class _IssueCard extends StatelessWidget {
  const _IssueCard({required this.issue});

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
            CopyButton(text: _issueText(issue), color: scheme.error),
          ],
        ),
      ),
    );
  }
}
