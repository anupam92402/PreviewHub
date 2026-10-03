import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';

/// Shown when no collection has anything matching the landing screen's
/// search.
class GlobalSearchNoResults extends StatelessWidget {
  /// Creates the empty state.
  const GlobalSearchNoResults({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.search_off_rounded,
            size: 34,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            PreviewHubStrings.searchEverythingEmpty,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
