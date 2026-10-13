import 'package:flutter/material.dart';

import '../../../../util/preview_hub_colors.dart';
import '../../../../util/preview_hub_strings.dart';

/// The validation report's body when every entry came back fine: a green tick
/// over a sentence saying how many entries were checked.
class ValidationAllClear extends StatelessWidget {
  /// Creates the all-clear covering [checkedCount] entries.
  const ValidationAllClear({required this.checkedCount, super.key});

  /// How many entries were checked.
  final int checkedCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    const Color good = PreviewHubColors.emerald;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 12),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: good.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            size: 30,
            color: good,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          PreviewHubStrings.validationReportEmpty,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          PreviewHubStrings.validationReportChecked(checkedCount),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
