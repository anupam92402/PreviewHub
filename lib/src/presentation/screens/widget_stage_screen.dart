import 'package:flutter/material.dart';

import '../../domain/models/widget_preview.dart';
import '../../preview_hub_strings.dart';

/// One registered screen, running at the size it will ship at.
///
/// A screen is given the whole display rather than a card in a list: shrunk
/// into a thumbnail it proves nothing about the layout it will really get.
class WidgetStageScreen extends StatelessWidget {
  /// Creates the stage for [preview].
  const WidgetStageScreen({required this.preview, super.key});

  /// Entry being shown, which carries exactly one case.
  final WidgetPreview preview;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: <Widget>[
        // Built through a Builder so the host screen gets its own element:
        // anything it throws surfaces here, not up the tree.
        Positioned.fill(
          child: Builder(builder: preview.usableCases.first.builder),
        ),
        // The dismiss control floats along the bottom rather than the top:
        // every screen puts something in its top corners, and an overlay
        // there covers the very thing being reviewed.
        Positioned(
          left: 16,
          bottom: MediaQuery.paddingOf(context).bottom + 12,
          child: const _StageCloseButton(),
        ),
      ],
    ),
  );
}

/// Floating dismiss control, laid over whatever the screen is drawing.
class _StageCloseButton extends StatelessWidget {
  const _StageCloseButton();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      shape: const CircleBorder(),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: PreviewHubStrings.widgetStageClose,
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Icon(Icons.close_rounded, color: scheme.onSurface, size: 20),
      ),
    );
  }
}
