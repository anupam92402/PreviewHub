import 'package:flutter/material.dart';

import '../../../domain/models/validation_issue.dart';
import 'validation/validation_all_clear.dart';
import 'validation/validation_problem_list.dart';

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
                ? ValidationAllClear(checkedCount: checkedCount)
                : ValidationProblemList(issues: issues),
          ),
        ),
      ),
    );
  }
}
