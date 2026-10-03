import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../domain/models/lottie_asset.dart';
import '../../../domain/models/preview_asset.dart';

/// Plays [asset] at [speed], looping or once, with the play state under the
/// caller's control. An [AnimationController] drives the animation rather
/// than Lottie animating itself, so pausing holds the current frame instead of
/// snapping to the first.
class LottiePlayer extends StatefulWidget {
  /// Creates a player for [asset].
  const LottiePlayer({
    required this.asset,
    required this.isPlaying,
    this.controller,
    this.onLoaded,
    this.onFailed,
    this.fit = BoxFit.contain,
    this.speed = 1,
    this.loop = true,
    super.key,
  });

  /// Animation to play.
  final LottieAsset asset;

  /// Whether the animation should be running.
  final bool isPlaying;

  /// Drives the animation instead of the player's own controller. Supplied when
  /// the caller needs more than start and stop. The caller keeps ownership and
  /// disposes it.
  final AnimationController? controller;

  /// Called once the composition has parsed, with what it describes.
  final ValueChanged<LottieComposition>? onLoaded;

  /// Called when the file cannot be played at all.
  final VoidCallback? onFailed;

  /// How the animation fills its box.
  final BoxFit fit;

  /// Playback rate, where 1 is the speed the animation was authored at.
  final double speed;

  /// Whether the animation starts over when it ends, or holds its last frame.
  final bool loop;

  @override
  State<LottiePlayer> createState() => _LottiePlayerState();
}

class _LottiePlayerState extends State<LottiePlayer>
    with SingleTickerProviderStateMixin {
  /// Made only when no controller was supplied, so a ticker is never created
  /// for a player that is being driven from outside.
  AnimationController? _ownController;

  AnimationController get _controller =>
      widget.controller ??
      (_ownController ??= AnimationController(vsync: this));

  LottieComposition? _composition;

  @override
  void didUpdateWidget(LottiePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.speed != oldWidget.speed) {
      _applyDuration();
    }
    if (widget.isPlaying != oldWidget.isPlaying ||
        widget.speed != oldWidget.speed ||
        widget.loop != oldWidget.loop) {
      _applyPlayState();
    }
  }

  /// Disposes only the controller this player made; a supplied one belongs to
  /// its caller and may outlive this widget.
  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  /// Stretches or squeezes the authored duration to the chosen speed.
  void _applyDuration() {
    final LottieComposition? composition = _composition;
    if (composition == null || widget.speed <= 0) {
      return;
    }
    _controller.duration = composition.duration * (1 / widget.speed);
  }

  /// Starts or holds the animation, without rewinding when it is held. Playing
  /// once from the last frame starts again from the first.
  void _applyPlayState() {
    if (_controller.duration == null) {
      return;
    }
    if (!widget.isPlaying) {
      _controller.stop();
    } else if (widget.loop) {
      _controller.repeat();
    } else if (_controller.value < 1) {
      _controller.forward();
    } else {
      /// Rewinding notifies the controller's listeners, which may sit outside
      /// this subtree, so it waits until the tree has finished building.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isPlaying && !widget.loop) {
          _controller.forward(from: 0);
        }
      });
    }
  }

  void _onLoaded(LottieComposition composition) {
    _composition = composition;
    _applyDuration();
    _applyPlayState();
    widget.onLoaded?.call(composition);
  }

  /// Reports the failure after the current frame, since error builders run
  /// during layout.
  Widget _onError(BuildContext context, Object error, StackTrace? stack) {
    final VoidCallback? onFailed = widget.onFailed;
    if (onFailed != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onFailed());
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) =>
      widget.asset.source == AssetSource.bundled
      ? Lottie.asset(
          widget.asset.locator,
          controller: _controller,
          onLoaded: _onLoaded,
          errorBuilder: _onError,
          fit: widget.fit,
        )
      : Lottie.network(
          widget.asset.locator,
          controller: _controller,
          onLoaded: _onLoaded,
          errorBuilder: _onError,
          fit: widget.fit,
        );
}
