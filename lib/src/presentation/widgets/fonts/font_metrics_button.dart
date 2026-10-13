import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';

/// App bar button that draws or hides the baseline on every sample line. Off,
/// it shows an outlined ruler; on, a filled ruler in the primary colour on a
/// tinted circle.
class FontMetricsButton extends StatelessWidget {
  /// Creates the button flipping [showMetrics].
  const FontMetricsButton({required this.showMetrics, super.key});

  /// Whether the baseline is drawn.
  final ValueNotifier<bool> showMetrics;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: showMetrics,
      builder: (BuildContext context, bool show, Widget? child) => IconButton(
        tooltip: show
            ? PreviewHubStrings.fontMetricsHide
            : PreviewHubStrings.fontMetricsShow,
        isSelected: show,
        onPressed: () => showMetrics.value = !show,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? scheme.primary.withValues(alpha: 0.12)
                : null,
          ),
        ),
        icon: const Icon(Icons.straighten_outlined),
        selectedIcon: const Icon(Icons.straighten),
      ),
    );
  }
}
