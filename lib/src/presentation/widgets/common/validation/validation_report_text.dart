import '../../../../domain/models/validation_issue.dart';

/// Plain-text form of one [ValidationIssue], ready to paste into a ticket or a
/// chat.
extension ValidationIssueReportText on ValidationIssue {
  /// The entry and its reason, on two lines.
  String get reportText => '$entry\n  $description';
}

/// Plain-text form of a whole validation report.
extension ValidationReportText on List<ValidationIssue> {
  /// Every issue's [ValidationIssueReportText.reportText], separated by a
  /// blank line.
  String get reportText =>
      map((ValidationIssue issue) => issue.reportText).join('\n\n');
}
