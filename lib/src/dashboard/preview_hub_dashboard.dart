import 'package:flutter/material.dart';

import '../domain/models/preview_hub_config.dart';
import '../domain/models/preview_hub_route_arguments.dart';
import '../presentation/routing/preview_hub_router.dart';
import '../presentation/routing/preview_hub_routes.dart';
import '../presentation/theme/preview_hub_theme_controller.dart';
import '../preview_hub_strings.dart';
import '../preview_section.dart';
import 'dashboard_header.dart';
import 'entrance_transition.dart';
import 'preview_section_card.dart';

/// Landing screen listing every previewable collection.
class PreviewHubDashboard extends StatefulWidget {
  const PreviewHubDashboard({
    this.config = const PreviewHubConfig(),
    super.key,
  });

  /// Tells the gallery about assets it cannot discover, such as remote URLs.
  final PreviewHubConfig config;

  @override
  State<PreviewHubDashboard> createState() => _PreviewHubDashboardState();
}

class _PreviewHubDashboardState extends State<PreviewHubDashboard> {
  final PreviewHubThemeController _themeController =
      PreviewHubThemeController();

  @override
  void dispose() {
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
        onSectionTap: _openSection,
      ),
    );
  }
}

/// The landing screen itself, below the gallery's own theme.
class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.themeController,
    required this.onSectionTap,
  });

  /// Theme the toggle flips.
  final PreviewHubThemeController themeController;

  /// Called when a collection card is tapped.
  final ValueChanged<PreviewSection> onSectionTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: DashboardHeader(
              onThemeToggle: () =>
                  themeController.toggle(Theme.of(context).brightness),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
            sliver: SliverToBoxAdapter(child: _SectionLabel()),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: PreviewSection.assetsList.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final PreviewSection section = PreviewSection.assetsList[index];
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
      ),
    );
  }
}

/// Heading above the section list.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Text(
          PreviewHubStrings.listLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: scheme.outlineVariant.withValues(alpha: 0.6),
            height: 1,
          ),
        ),
      ],
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
