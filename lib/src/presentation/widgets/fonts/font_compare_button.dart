import 'package:flutter/material.dart';

import '../../../domain/models/font_family_info.dart';
import '../../../domain/models/preview_hub_route_arguments.dart';
import '../../../routing/preview_hub_router.dart';
import '../../../routing/preview_hub_routes.dart';
import '../../../theme/preview_hub_theming.dart';
import '../../../util/preview_hub_strings.dart';

/// App bar button that opens the comparison of two families.
class FontCompareButton extends StatelessWidget {
  /// Creates the button offering [families] to compare.
  const FontCompareButton({required this.families, super.key});

  /// Families either side of the comparison can be set in.
  final List<FontFamilyInfo> families;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: PreviewHubStrings.fontCompareTooltip,
    onPressed: () => Navigator.of(context).push(
      PreviewHubRouter.route(
        PreviewHubRoutes.fontCompare,
        arguments: FontCompareArguments(
          families: families,
          themeController: PreviewHubTheming.controllerOf(context),
        ),
      ),
    ),
    icon: const Icon(Icons.compare_arrows_rounded),
  );
}
