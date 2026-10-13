import 'package:flutter/material.dart';

import '../../../domain/models/preview_hub_config.dart';
import '../../../domain/models/preview_hub_route_arguments.dart';
import '../../../domain/models/widget_preview.dart';
import '../../../preview_section.dart';
import '../../../session/preview_history.dart';
import '../../../theme/preview_hub_theme_controller.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/global_search_view_model.dart';
import '../common/preview_search_bar.dart';
import 'dashboard_footnote.dart';
import 'dashboard_header.dart';
import 'dashboard_section_label.dart';
import 'entrance_transition.dart';
import 'global_search_results.dart';
import 'preview_section_card.dart';
import 'recent_previews.dart';

/// The landing screen itself, below the gallery's own theme.
class DashboardBody extends StatelessWidget {
  /// Creates the landing screen's content.
  const DashboardBody({
    required this.themeController,
    required this.search,
    required this.config,
    required this.onSectionTap,
    required this.onPreviewTap,
    required this.onPush,
    super.key,
  });

  /// Theme the toggle flips.
  final PreviewHubThemeController themeController;

  /// The search across every collection.
  final GlobalSearchViewModel search;

  /// What the host supplied: widget entries for the recently viewed row, and
  /// remote assets for the size breakdown to pass on.
  final PreviewHubConfig config;

  /// Called when a collection card is tapped.
  final ValueChanged<PreviewSection> onSectionTap;

  /// Called when a widget entry is tapped, in the results or the recents.
  final ValueChanged<WidgetPreview> onPreviewTap;

  /// Pushes a gallery route, for asset results.
  final void Function(String name, PreviewHubArguments arguments) onPush;

  /// Builds the landing screen. While a search is active its results take
  /// the place of the recents and the collection cards.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: search,
        builder: (BuildContext context, Widget? child) => CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: DashboardHeader(
                config: config,
                onThemeToggle: () =>
                    themeController.toggle(Theme.of(context).brightness),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              sliver: SliverToBoxAdapter(
                child: PreviewSearchBar(
                  hintText: PreviewHubStrings.searchEverythingHint,
                  onChanged: search.search,
                ),
              ),
            ),
            if (search.isActive)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.paddingOf(context).bottom + 28,
                ),
                sliver: SliverToBoxAdapter(
                  child: GlobalSearchResults(
                    searchVM: search,
                    themeController: themeController,
                    onPreviewTap: onPreviewTap,
                    onPush: onPush,
                  ),
                ),
              )
            else ...<Widget>[
              SliverToBoxAdapter(
                child: RecentPreviews(
                  history: PreviewHistory.instance,
                  previews: config.widgets,
                  onTap: onPreviewTap,
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                sliver: SliverToBoxAdapter(
                  child: DashboardSectionLabel(
                    label: PreviewHubStrings.listLabel,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: PreviewSection.assetsList.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final PreviewSection section =
                        PreviewSection.assetsList[index];
                    return EntranceTransition(
                      delay: Duration(milliseconds: 70 * index),
                      child: PreviewSectionCard(
                        section: section,
                        onTap: () => onSectionTap(section),
                      ),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  MediaQuery.paddingOf(context).bottom + 28,
                ),
                sliver: const SliverToBoxAdapter(child: DashboardFootnote()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
