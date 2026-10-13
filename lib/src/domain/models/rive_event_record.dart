import 'package:flutter/foundation.dart';

/// What kind of event a Rive state machine reported.
enum RiveEventKind {
  /// A plain named event, perhaps carrying custom properties.
  general,

  /// An event asking the app to open a URL.
  openUrl,

  /// An event playing a sound.
  audio,
}

/// One event a Rive state machine reported, copied out of the runtime so it
/// can be listed after the runtime has moved on.
@immutable
class RiveEventRecord {
  /// Records an event called [name], reported [elapsed] after start.
  const RiveEventRecord({
    required this.name,
    required this.kind,
    required this.elapsed,
    this.detail,
    this.properties = const <String>[],
  });

  /// Name given in the Rive editor.
  final String name;

  /// What kind of event it is.
  final RiveEventKind kind;

  /// How long after the animation started it fired.
  final Duration elapsed;

  /// The URL of an open-URL event or the sound of an audio event, else null.
  final String? detail;

  /// Custom properties attached to it, each as `name: value`.
  final List<String> properties;
}
