import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';
import 'shimmer_border.dart';

/// Small capsule carrying the product name, with a ray of light running round
/// its outline.
class DashboardHeaderBadge extends StatelessWidget {
  /// Creates the badge.
  const DashboardHeaderBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ShimmerBorder(
      color: scheme.primary,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.auto_awesome_rounded, size: 14, color: scheme.primary),
            const SizedBox(width: 7),
            Text(
              PreviewHubStrings.badgeLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
