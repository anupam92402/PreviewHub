import 'package:flutter/material.dart';

import '../domain/models/preview_hub_config.dart';
import '../domain/models/preview_hub_route_arguments.dart';
import '../domain/models/widget_preview.dart';
import '../presentation/routing/preview_hub_router.dart';
import '../presentation/routing/preview_hub_routes.dart';
import '../presentation/session/preview_history.dart';
import '../presentation/theme/preview_hub_theme_controller.dart';
import '../presentation/viewmodels/global_search_view_model.dart';
import '../presentation/widgets/preview_search_bar.dart';
import '../preview_hub_strings.dart';
import '../preview_section.dart';
import 'dashboard_header.dart';
import 'dashboard_section_label.dart';
import 'entrance_transition.dart';
import 'global_search_results.dart';
import 'preview_section_card.dart';
import 'recent_previews.dart';

/// Landing screen listing every previewable collection.
class PreviewHubDashboard extends StatefulWidget {
  /// Creates the landing screen. [initialPreview] opens one entry straight
  /// away, as `group/title` or just the title, so a hot restart lands back on
  /// the widget being worked on.
  const PreviewHubDashboard({
    this.config = const PreviewHubConfig(),
    this.initialPreview,
    super.key,
  });

  /// Tells the gallery about assets it cannot discover, such as remote URLs.
  final PreviewHubConfig config;

  /// Entry to open on arrival, as `group/title` or its title alone. Ignored
  /// when no registered entry matches.
  final String? initialPreview;

  @override
  State<PreviewHubDashboard> createState() => _PreviewHubDashboardState();
}

class _PreviewHubDashboardState extends State<PreviewHubDashboard> {
  final PreviewHubThemeController _themeController =
      PreviewHubThemeController();
  late final GlobalSearchViewModel _search = GlobalSearchViewModel(
    config: widget.config,
  );

  @override
  void initState() {
    super.initState();
    final String? initial = widget.initialPreview;
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openPath(initial));
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _themeController.dispose();
    super.dispose();
  }

  /// Opens the collection behind [section], for the ones that exist yet.
  /// Switching over the type rather than testing one case means a collection
  /// added later will not silently fall through to doing nothing.
  void _openSection(PreviewSection section) {
    switch (section.type) {
      case PreviewSectionType.iconsAndImages:
        _push(
          PreviewHubRoutes.iconsAndImages,
          IconsAndImagesArguments(
            config: widget.config,
            themeController: _themeController,
          ),
        );

      case PreviewSectionType.fonts:
        _push(
          PreviewHubRoutes.fonts,
          FontsArguments(themeController: _themeController),
        );

      case PreviewSectionType.lottie:
        _push(
          PreviewHubRoutes.lottie,
          LottieArguments(
            config: widget.config,
            themeController: _themeController,
          ),
        );

      case PreviewSectionType.rive:
        _push(
          PreviewHubRoutes.rive,
          RiveArguments(
            config: widget.config,
            themeController: _themeController,
          ),
        );

      case PreviewSectionType.widgets:
        _push(
          PreviewHubRoutes.widgets,
          WidgetsArguments(
            config: widget.config,
            themeController: _themeController,
          ),
        );

      case PreviewSectionType.other:
        _push(
          PreviewHubRoutes.otherAssets,
          OtherAssetsArguments(themeController: _themeController),
        );
    }
  }

  /// Opens the entry registered at [path], by way of the widget index so the
  /// back button lands somewhere sensible.
  void _openPath(String path) {
    if (!mounted) {
      return;
    }
    final WidgetPreview? preview = widget.config.widgets
        .where(
          (WidgetPreview item) =>
              item.isUsable && (item.path == path || item.title == path),
        )
        .firstOrNull;
    if (preview == null) {
      return;
    }
    _push(
      PreviewHubRoutes.widgets,
      WidgetsArguments(
        config: widget.config,
        themeController: _themeController,
      ),
    );
    _openPreview(preview);
  }

  /// Opens [preview] on its own page and remembers it as recently opened.
  void _openPreview(WidgetPreview preview) {
    PreviewHistory.instance.recordOpened(preview.path);
    switch (preview.section) {
      case WidgetSection.components:
        _push(
          PreviewHubRoutes.widgetDetail,
          WidgetDetailArguments(
            preview: preview,
            themeController: _themeController,
          ),
        );
      case WidgetSection.screens:
        _push(
          PreviewHubRoutes.widgetStage,
          WidgetStageArguments(
            preview: preview,
            themeController: _themeController,
          ),
        );
    }
  }

  void _push(String name, PreviewHubArguments arguments) => Navigator.of(
    context,
  ).push(PreviewHubRouter.route(name, arguments: arguments));

  @override
  Widget build(BuildContext context) {
    return PreviewHubTheming(
      controller: _themeController,
      child: _DashboardBody(
        themeController: _themeController,
        search: _search,
        previews: widget.config.widgets,
        onSectionTap: _openSection,
        onPreviewTap: _openPreview,
        onPush: _push,
      ),
    );
  }
}

/// The landing screen itself, below the gallery's own theme.
class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.themeController,
    required this.search,
    required this.previews,
    required this.onSectionTap,
    required this.onPreviewTap,
    required this.onPush,
  });

  /// Theme the toggle flips.
  final PreviewHubThemeController themeController;

  /// The search across every collection.
  final GlobalSearchViewModel search;

  /// Registered widget entries, for the recently viewed row.
  final List<WidgetPreview> previews;

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
                  previews: previews,
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
                sliver: const SliverToBoxAdapter(child: _Footnote()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Closing nudge under the section list.
class _Footnote extends StatelessWidget {
  const _Footnote();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.bolt_rounded,
          size: 18,
          color: scheme.primary.withValues(alpha: 0.85),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            PreviewHubStrings.footnote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
