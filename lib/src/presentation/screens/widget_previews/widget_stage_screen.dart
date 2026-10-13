import 'package:flutter/material.dart';

import '../../../domain/models/widget_preview.dart';
import '../../widgets/widget_previews/widget_stage_close_button.dart';

/// One registered screen, running at the size it will ship at. The screen
/// gets the whole display: a thumbnail proves nothing about the layout it
/// will really receive.
class WidgetStageScreen extends StatelessWidget {
  /// Creates the stage for [preview].
  const WidgetStageScreen({required this.preview, super.key});

  /// Entry being shown, which carries exactly one case.
  final WidgetPreview preview;

  /// Builds the stage. The case goes through a Builder so a throwing host
  /// screen fails in its own element, and the dismiss control sits at the
  /// bottom, clear of the corners screens normally occupy.
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: <Widget>[
        Positioned.fill(
          child: Builder(builder: preview.usableCases.first.builder),
        ),
        Positioned(
          left: 16,
          bottom: MediaQuery.paddingOf(context).bottom + 12,
          child: const WidgetStageCloseButton(),
        ),
      ],
    ),
  );
}
