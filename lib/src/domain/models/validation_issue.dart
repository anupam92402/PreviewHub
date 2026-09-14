import 'package:flutter/foundation.dart';

/// Why a supplied entry could not be shown, or looks wrong.
enum ValidationFailure {
  /// The string could not be parsed as a URL at all.
  malformedUrl('Not a valid URL'),

  /// Parsed, but the scheme is something other than http or https.
  unsupportedScheme('Only http and https are supported'),

  /// A valid URL that does not end in a supported image extension.
  unsupportedFormat('Not a supported image format'),

  /// Fetched, but the server described the body as something other than an
  /// image.
  unexpectedContentType('Server did not return an image'),

  /// The server could not be reached, or answered with an error.
  unreachable('Could not be reached');

  const ValidationFailure(this.message);

  /// Plain-language explanation shown in the report.
  final String message;
}

/// One rejected or suspect entry, kept so it can be shown rather than dropped.
@immutable
class ValidationIssue {
  /// Records that [entry] failed with [failure].
  const ValidationIssue({
    required this.entry,
    required this.failure,
    this.detail,
  });

  /// The entry exactly as the consumer supplied it.
  final String entry;

  /// What was wrong with it.
  final ValidationFailure failure;

  /// Extra context, such as a status code or the content type actually served.
  final String? detail;

  @override
  bool operator ==(Object other) =>
      other is ValidationIssue &&
      other.entry == entry &&
      other.failure == failure;

  @override
  int get hashCode => Object.hash(entry, failure);
}
