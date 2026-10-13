import 'dart:async';

import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/rive_event_log.dart';
import 'rive_events_sheet.dart';

/// App bar button opening the events the animation has reported, badged with
/// how many there are. Disabled until the first one arrives, which is
/// announced with a brief tooltip.
class RiveEventsButton extends StatefulWidget {
  /// Creates the button over [log].
  const RiveEventsButton({required this.log, super.key});

  /// Events counted and listed.
  final RiveEventLog log;

  @override
  State<RiveEventsButton> createState() => _RiveEventsButtonState();
}

class _RiveEventsButtonState extends State<RiveEventsButton> {
  /// How long the first-event tooltip stays up.
  static const Duration _announcement = Duration(seconds: 2);

  final GlobalKey<TooltipState> _tooltip = GlobalKey<TooltipState>();
  Timer? _hide;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _count = widget.log.count;
    widget.log.addListener(_onLogChanged);
  }

  @override
  void dispose() {
    widget.log.removeListener(_onLogChanged);
    _hide?.cancel();
    super.dispose();
  }

  /// Announces the first event of a run; a cleared list counts from zero
  /// again, so the next first event is announced too.
  void _onLogChanged() {
    final int previous = _count;
    _count = widget.log.count;
    if (previous == 0 && _count > 0) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (!mounted) {
          return;
        }
        _tooltip.currentState?.ensureTooltipVisible();
        _hide?.cancel();
        _hide = Timer(_announcement, Tooltip.dismissAllToolTips);
      });
    }
  }

  void _open() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      builder: (BuildContext context) => RiveEventsSheet(log: widget.log),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.log,
    builder: (BuildContext context, Widget? child) {
      final int count = widget.log.count;
      return Tooltip(
        key: _tooltip,
        message: PreviewHubStrings.riveEventsReceived,
        triggerMode: TooltipTriggerMode.manual,
        child: Semantics(
          label: PreviewHubStrings.riveEvents,
          child: IconButton(
            onPressed: count == 0 ? null : _open,
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ),
      );
    },
  );
}
