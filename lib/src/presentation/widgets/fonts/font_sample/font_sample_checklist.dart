import 'package:flutter/material.dart';

import '../../../../util/preview_hub_strings.dart';
import '../../../viewmodels/font_sample_view_model.dart';
import 'font_sample_checklist_row.dart';

/// What is chosen and what is not, shown before the sample field opens.
class FontSampleChecklist extends StatelessWidget {
  /// Creates the checklist reflecting [viewModel].
  const FontSampleChecklist({required this.viewModel, super.key});

  /// Source of the missing choices.
  final FontSampleViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<String> missing = viewModel.missingChoices;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            PreviewHubStrings.fontSampleChecklist,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          for (final String field in <String>[
            PreviewHubStrings.fontFieldFamily,
            PreviewHubStrings.fontFieldWeight,
            PreviewHubStrings.fontFieldSize,
          ])
            FontSampleChecklistRow(
              label: field,
              done: !missing.contains(field),
            ),
        ],
      ),
    );
  }
}
