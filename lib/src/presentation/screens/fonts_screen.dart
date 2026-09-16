import 'package:flutter/material.dart';

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/font_family_info.dart';
import '../../domain/models/preview_hub_route_arguments.dart';
import '../../domain/services/font_catalog_service.dart';
import '../../domain/services/font_metrics_service.dart';
import '../../preview_hub_strings.dart';
import '../routing/preview_hub_router.dart';
import '../routing/preview_hub_routes.dart';
import '../theme/preview_hub_theme_controller.dart';
import '../viewmodels/fonts_view_model.dart';
import '../widgets/font_weight_section.dart';
import '../widgets/preview_filter_bar.dart';
import '../widgets/preview_search_bar.dart';

/// Every font family bundled with the app, shown one family at a time.
/// Families come from the font manifest; nothing is registered by hand.
class FontsScreen extends StatefulWidget {
  /// Creates the screen.
  const FontsScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Builds the family view; the sample action stays hidden until a family
  /// loads, so the sheet can never open with an empty family list.
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _viewModel,
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
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _FontsHeader(viewModel: _viewModel),
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
                    _FamilySummary(
                      family: family,
                      sizeInBytes: _viewModel.totalSizeOf(family),
                    ),
                    const SizedBox(height: 20),
                    for (final FontFace face in family.faces)
                      FontWeightSection(
                        family: family,
                        face: face,
                        sizeInBytes: _viewModel.sizeOf(face),
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

/// Search field and the family chips, shown while the bar is expanded.
class _FontsHeader extends StatelessWidget {
  const _FontsHeader({required this.viewModel});

  final FontsViewModel viewModel;

  /// Offsets the controls clear of the toolbar and status bar, which the
  /// flexible space reaches behind.
  @override
  Widget build(BuildContext context) {
    final List<FontFamilyInfo> families = viewModel.visibleFamilies;

    return Padding(
      padding: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.paddingOf(context).top,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: PreviewSearchBar(
              hintText: PreviewHubStrings.searchFontsHint,
              resultCount: families.length,
              onChanged: viewModel.search,
            ),
          ),
          PreviewFilterBar(
            groups: <PreviewFilterGroup>[
              PreviewFilterGroup(
                label: PreviewHubStrings.fontFamilyFilterLabel,
                filters: <PreviewFilter>[
                  for (final FontFamilyInfo family in families)
                    PreviewFilter(
                      label: family.name,
                      selected: viewModel.selected == family,
                      onSelected: () => viewModel.select(family),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The open family's name, set in itself, with its weight and file count.
class _FamilySummary extends StatelessWidget {
  const _FamilySummary({required this.family, required this.sizeInBytes});

  final FontFamilyInfo family;
  final int? sizeInBytes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                family.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: family.manifestKey,
                  fontSize: 26,
                  fontWeight: family.representativeFace.fontWeight,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                PreviewHubStrings.fontFaceCount(family.faces.length),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (sizeInBytes != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AssetMetrics.formatBytes(sizeInBytes),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
