import 'dart:async';

import 'package:flutter/material.dart';

/// Fades and lifts [child] into place once, after [delay].
class EntranceTransition extends StatefulWidget {
  /// Creates an entrance animation for [child].
  const EntranceTransition({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  /// Widget being animated in.
  final Widget child;

  /// Time to wait before the animation starts.
  final Duration delay;

  @override
  State<EntranceTransition> createState() => _EntranceTransitionState();
}

class _EntranceTransitionState extends State<EntranceTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _startTimer = Timer(widget.delay, _controller.forward);
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curve,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(_curve),
      child: widget.child,
    ),
  );
}
