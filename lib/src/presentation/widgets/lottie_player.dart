import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../domain/models/lottie_asset.dart';
import '../../domain/models/preview_asset.dart';
import '../../preview_hub_strings.dart';

/// Plays [asset], looping, with the play state under the caller's control.
/// Drives its own [AnimationController] rather than letting Lottie animate
/// itself, so pausing holds the current frame instead of snapping to the first.
class LottiePlayer extends StatefulWidget {
  /// Creates a player for [asset].
  const LottiePlayer({
    required this.asset,
    required this.isPlaying,
    this.controller,
    this.onLoaded,
    this.onFailed,
    this.fit = BoxFit.contain,
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

  @override
  void didUpdateWidget(LottiePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
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

  /// Starts or holds the animation, without rewinding when it is held.
  void _applyPlayState() {
    if (widget.isPlaying) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  void _onLoaded(LottieComposition composition) {
    _controller.duration = composition.duration;
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

/// Stands in for an animation that could not be played.
class LottiePlayerFailure extends StatelessWidget {
  /// Creates a failure panel tinted with [accent].
  const LottiePlayerFailure({
    required this.accent,
    this.iconSize = 28,
    super.key,
  });

  /// Colour of the glyph and caption.
  final Color accent;

  /// Largest the glyph is allowed to be.
  final double iconSize;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final double glyph = iconSize.clamp(
        12,
        constraints.biggest.shortestSide * 0.5,
      );
      final bool showCaption = constraints.maxHeight >= glyph * 2.4;

      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.motion_photos_off_outlined, size: glyph, color: accent),
          if (showCaption) ...<Widget>[
            SizedBox(height: glyph * 0.18),
            Flexible(
              child: Text(
                PreviewHubStrings.lottieFailed,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: glyph * 0.36, color: accent),
              ),
            ),
          ],
        ],
      );
    },
  );
}
