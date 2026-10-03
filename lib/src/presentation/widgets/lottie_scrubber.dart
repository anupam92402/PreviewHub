import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../preview_hub_strings.dart';

/// A slider over an animation's whole timeline, with the current frame beside
/// it. Disabled until the composition has loaded.
class LottieScrubber extends StatelessWidget {
  /// Creates a scrubber moving [controller] through [composition].
  const LottieScrubber({
    required this.controller,
    required this.composition,
    required this.onChangeStart,
    required this.onChanged,
    super.key,
  });

  /// Drives the animation; the slider follows and moves it.
  final AnimationController controller;

  /// Loaded animation, or null while it is still loading.
  final ValueListenable<LottieComposition?> composition;

  /// Called when a drag begins, so playback can be held.
  final ValueChanged<double> onChangeStart;

  /// Called with the new position, from 0 to 1.
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[controller, composition]),
      builder: (BuildContext context, Widget? child) {
        final LottieComposition? loaded = composition.value;
        final double progress = controller.value.clamp(0, 1);
        return Row(
          children: <Widget>[
            Expanded(
              child: Slider(
                value: progress,
                onChangeStart: loaded == null ? null : onChangeStart,
                onChanged: loaded == null ? null : onChanged,
              ),
            ),
            SizedBox(
              width: 76,
              child: Text(
                loaded == null
                    ? '—'
                    : PreviewHubStrings.lottieFrame(
                        (loaded.startFrame + progress * loaded.durationFrames)
                            .round(),
                        loaded.endFrame.round(),
                      ),
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
