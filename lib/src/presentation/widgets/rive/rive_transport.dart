import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import '../../../util/preview_hub_strings.dart';

/// Play, pause and restart, side by side. Restart stays disabled until the
/// file loads, since before that there is no first frame to return to.
class RiveTransport extends StatelessWidget {
  /// Creates the transport editing [isPlaying] and restarting via [onRestart].
  const RiveTransport({
    required this.isPlaying,
    required this.controller,
    required this.onRestart,
    super.key,
  });

  /// Whether the animation is running.
  final ValueNotifier<bool> isPlaying;

  /// Loaded animation's controller, or null while the file is still loading.
  final ValueNotifier<rive.RiveWidgetController?> controller;

  /// Called to play the animation from the start again.
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      ValueListenableBuilder<bool>(
        valueListenable: isPlaying,
        builder: (BuildContext context, bool playing, Widget? child) =>
            FilledButton.tonalIcon(
              onPressed: () => isPlaying.value = !playing,
              icon: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 18,
              ),
              label: Text(
                playing
                    ? PreviewHubStrings.lottiePause
                    : PreviewHubStrings.lottiePlay,
              ),
            ),
      ),
      const SizedBox(width: 12),
      ValueListenableBuilder<rive.RiveWidgetController?>(
        valueListenable: controller,
        builder:
            (
              BuildContext context,
              rive.RiveWidgetController? loaded,
              Widget? child,
            ) => OutlinedButton.icon(
              onPressed: loaded == null ? null : onRestart,
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: const Text(PreviewHubStrings.lottieRestart),
            ),
      ),
    ],
  );
}
