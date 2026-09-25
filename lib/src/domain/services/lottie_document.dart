import 'dart:convert';

/// Tells a Lottie animation from any other JSON file.
///
/// A Lottie is Bodymovin JSON, and an app bundles plenty of JSON that is not:
/// translations, remote config, mock responses, a `dotlottie` manifest. Only
/// the document itself says which it is, so the gallery reads it rather than
/// trusting the `.json` extension.
class LottieDocument {
  const LottieDocument._();

  /// Whether [source] is a Lottie animation document.
  ///
  /// Requires the two things every Bodymovin export carries and no ordinary
  /// JSON file does: a top-level `layers` list, and the timing a renderer
  /// needs — a schema version, or a frame rate together with an out point.
  /// Anything that parses as something else, or does not parse at all, is not
  /// an animation.
  static bool describesAnimation(String source) {
    final Object? document;
    try {
      document = jsonDecode(source);
    } on Object catch (_) {
      return false;
    }

    if (document is! Map<String, Object?> || document['layers'] is! List) {
      return false;
    }

    final Object? version = document['v'];
    return version is String ||
        version is num ||
        (document['fr'] is num && document['op'] is num);
  }
}
