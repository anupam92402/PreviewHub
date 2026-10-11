import 'package:flutter/material.dart';

import '../../../domain/models/font_family_info.dart';
import '../../../domain/models/preview_hub_route_arguments.dart';
import '../../../domain/services/font_catalog_service.dart';
import '../../../domain/services/font_metrics_service.dart';
import '../../../routing/preview_hub_router.dart';
import '../../../routing/preview_hub_routes.dart';
import '../../../theme/preview_hub_theming.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/fonts_view_model.dart';
import '../../widgets/common/preview_filter_bar.dart';
import '../../widgets/fonts/font_compare_button.dart';
import '../../widgets/fonts/font_family_summary.dart';
import '../../widgets/fonts/font_metrics_button.dart';
import '../../widgets/fonts/font_missing_weights.dart';
import '../../widgets/fonts/font_weight_section.dart';
import '../../widgets/fonts/fonts_header.dart';

/// Every font family bundled with the app, shown one family at a time.
/// Families come from the font manifest; nothing is registered by hand. Each
/// family lists the weights it ships no file for, and the app bar draws
/// baselines or opens a comparison of two families.
class FontsScreen extends StatefulWidget {
  /// Creates the screen, opening on the family whose manifest key is
  /// [initialFamily], or on the first family.
  const FontsScreen({this.initialFamily, super.key});

  /// Manifest key of the family to open on.
  final String? initialFamily;

  @override
  State<FontsScreen> createState() => _FontsScreenState();
}

class _FontsScreenState extends State<FontsScreen> {
  /// Room the search field needs, including the gap beneath it.
  static const double _searchHeight = 60;

  late final FontsViewModel _viewModel = FontsViewModel(
    catalog: FontCatalogService(),
    metrics: FontMetricsService(),
  );

  /// Whether every sample line draws its baseline.
  final ValueNotifier<bool> _showMetrics = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _viewModel.load(initialFamily: widget.initialFamily);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _showMetrics.dispose();
    super.dispose();
  }

  /// Builds the family view; the sample button stays hidden while no family is
  /// visible, so the sample screen never opens with an empty family list, and
  /// the compare button while there is no second family to compare with.
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge(<Listenable>[_viewModel, _showMetrics]),
    builder: (BuildContext context, Widget? child) {
      final FontFamilyInfo? family = _viewModel.selected;
      final List<FontFamilyInfo> families = _viewModel.visibleFamilies;

      return Scaffold(
        floatingActionButton: families.isEmpty
            ? null
            : FloatingActionButton(
                tooltip: PreviewHubStrings.fontSampleTooltip,
                onPressed: () => Navigator.of(context).push(
                  PreviewHubRouter.route(
                    PreviewHubRoutes.fontSample,
                    arguments: FontSampleArguments(
                      families: families,
                      themeController: PreviewHubTheming.controllerOf(context),
                    ),
                  ),
                ),
                child: const Icon(Icons.edit_rounded),
              ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight:
                  kToolbarHeight +
                  MediaQuery.textScalerOf(
                    context,
                  ).scale(_searchHeight + PreviewFilterBar.heightFor(1)),
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              title: const Text(PreviewHubStrings.sectionFontsTitle),
              actions: <Widget>[
                FontMetricsButton(showMetrics: _showMetrics),
                if (_viewModel.families.length > 1)
                  FontCompareButton(families: _viewModel.families),
                const SizedBox(width: 4),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: FontsHeader(viewModel: _viewModel),
              ),
            ),
            if (_viewModel.isLoading || family == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                sliver: SliverList.list(
                  children: <Widget>[
                    FontFamilySummary(
                      family: family,
                      sizeInBytes: _viewModel.totalSizeOf(family),
                    ),
                    const SizedBox(height: 14),
                    FontMissingWeights(family: family),
                    const SizedBox(height: 6),
                    for (final FontFace face in family.faces)
                      FontWeightSection(
                        family: family,
                        face: face,
                        sizeInBytes: _viewModel.sizeOf(face),
                        showMetrics: _showMetrics.value,
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
    },
  );
}
