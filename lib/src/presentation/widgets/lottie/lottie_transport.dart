import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';
import 'lottie_loop_picker.dart';

/// Play or pause, and loop or once, side by side. Playing a single run again
/// after it has ended starts from the first frame.
class LottieTransport extends StatelessWidget {
  /// Creates the transport editing [isPlaying] and [loop].
  const LottieTransport({
    required this.isPlaying,
    required this.loop,
    super.key,
  });

  /// Whether the animation is running.
  final ValueNotifier<bool> isPlaying;

  /// Whether the animation plays on repeat rather than once.
  final ValueNotifier<bool> loop;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge(<Listenable>[isPlaying, loop]),
    builder: (BuildContext context, Widget? child) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FilledButton.tonalIcon(
          onPressed: () => isPlaying.value = !isPlaying.value,
          icon: Icon(
            isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 18,
          ),
          label: Text(
            isPlaying.value
                ? PreviewHubStrings.lottiePause
                : PreviewHubStrings.lottiePlay,
          ),
        ),
        const SizedBox(width: 12),
        LottieLoopPicker(
          loop: loop.value,
          onChanged: (bool value) => loop.value = value,
        ),
      ],
    ),
  );
}
