import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';

/// Floating dismiss control on the widget stage, laid over whatever the
/// screen is drawing.
class WidgetStageCloseButton extends StatelessWidget {
  /// Creates the dismiss control.
  const WidgetStageCloseButton({super.key});

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
