import 'package:flutter/material.dart';

import '../../../viewmodels/font_sample_view_model.dart';
import 'font_sample_checklist.dart';
import 'font_sample_placeholder.dart';
import 'font_sample_preview.dart';

/// The preview area of the type tester: the sample, the placeholder, or what
/// is still missing.
class FontSampleStage extends StatelessWidget {
  /// Creates the stage reflecting [viewModel].
  const FontSampleStage({required this.viewModel, super.key});

  /// Source of the choices and the typed text.
  final FontSampleViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: switch ((viewModel.isComplete, viewModel.hasPreview)) {
        (false, _) => FontSampleChecklist(viewModel: viewModel),
        (true, false) => const FontSamplePlaceholder(),
        (true, true) => FontSamplePreview(viewModel: viewModel),
      },
    );
  }
}
