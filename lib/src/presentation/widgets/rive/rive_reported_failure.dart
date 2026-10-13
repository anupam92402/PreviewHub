import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import '../../../util/preview_hub_strings.dart';
import '../common/animation_playback_failure.dart';

/// Shows the failure panel and reports the failure after the frame.
/// [rive.RiveWidgetBuilder] does not call `onFailed` for its failed state, and
/// builders run during layout.
class RiveReportedFailure extends StatelessWidget {
  /// Creates the panel, calling [onFailed] once the frame has been built.
  const RiveReportedFailure({required this.onFailed, super.key});

  /// Called after the frame to report that the file could not be played.
  final VoidCallback onFailed;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onFailed());
    return AnimationPlaybackFailure(
      message: PreviewHubStrings.riveFailed,
      accent: Theme.of(context).colorScheme.error,
    );
  }
}
