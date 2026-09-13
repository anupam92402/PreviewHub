import 'package:flutter/material.dart';

import '../preview_hub_strings.dart';
import '../preview_section.dart';
import 'dashboard_header.dart';
import 'entrance_transition.dart';
import 'preview_section_card.dart';

/// Landing screen listing every previewable collection.
class PreviewHubDashboard extends StatelessWidget {
  /// Creates the landing screen.
  const PreviewHubDashboard({this.onThemeToggle, super.key});

  /// Called when the theme toggle is tapped; `null` hides it.
  final VoidCallback? onThemeToggle;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: DashboardHeader(onThemeToggle: onThemeToggle),
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
                child: PreviewSectionCard(section: section, onTap: () {}),
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
