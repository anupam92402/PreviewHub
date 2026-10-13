import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart' as rive;

import '../../domain/models/rive_event_record.dart';

/// The events the playing Rive state machine has reported, newest first.
/// Listens to one controller at a time; attaching the next one, after a
/// restart, starts its clock again.
class RiveEventLog extends ChangeNotifier {
  /// Most events kept; older ones drop off the end.
  static const int limit = 50;

  /// Times events from when the current controller was attached.
  final Stopwatch _clock = Stopwatch();

  /// Events reported during the current frame, listed once it has finished.
  final List<RiveEventRecord> _pending = <RiveEventRecord>[];

  rive.StateMachine? _machine;
  List<RiveEventRecord> _events = const <RiveEventRecord>[];
  bool _disposed = false;

  /// Events reported so far, newest first.
  List<RiveEventRecord> get events => _events;

  /// How many events are listed.
  int get count => _events.length;

  /// Starts listening to [controller]'s state machine instead of any other.
  void attach(rive.RiveWidgetController controller) {
    _detach();
    _machine = controller.stateMachine..addEventListener(_onEvent);
    _clock
      ..reset()
      ..start();
  }

  /// Empties the list.
  void clear() {
    _pending.clear();
    if (_events.isEmpty) {
      return;
    }
    _events = const <RiveEventRecord>[];
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _detach();
    super.dispose();
  }

  void _detach() {
    _machine?.removeEventListener(_onEvent);
    _machine = null;
  }

  /// Copies [event] out of the runtime. The state machine reports events while
  /// the animation is painted, when widgets must not rebuild, so they are held
  /// and listed after the frame.
  void _onEvent(rive.Event event) {
    _pending.add(
      RiveEventRecord(
        name: event.name,
        elapsed: _clock.elapsed,
        kind: switch (event) {
          rive.OpenUrlEvent() => RiveEventKind.openUrl,
          rive.AudioRuntimeEvent() => RiveEventKind.audio,
          _ => RiveEventKind.general,
        },
        detail: switch (event) {
          final rive.OpenUrlEvent event => event.url,
          final rive.AudioRuntimeEvent event => event.assetName,
          _ => null,
        },
        properties: <String>[
          for (final MapEntry<String, rive.CustomProperty> entry
              in event.properties.entries)
            '${entry.key}: ${entry.value.value}',
        ],
      ),
    );
    if (_pending.length == 1) {
      SchedulerBinding.instance
        ..addPostFrameCallback((Duration _) => _flush())
        ..ensureVisualUpdate();
    }
  }

  /// Lists the events held during the last frame, newest first.
  void _flush() {
    if (_disposed || _pending.isEmpty) {
      return;
    }
    _events = <RiveEventRecord>[
      ..._pending.reversed,
      ..._events,
    ].take(limit).toList(growable: false);
    _pending.clear();
    notifyListeners();
  }
}
