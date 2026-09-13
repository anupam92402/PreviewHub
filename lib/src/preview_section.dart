import 'package:flutter/material.dart';

import 'preview_hub_strings.dart';

/// A collection listed on the landing screen.
enum PreviewSectionType {
  /// Widget previews.
  widgets,

  /// SVG and raster artwork.
  iconsAndImages,

  /// Font families.
  fonts,

  /// Lottie animations.
  lottie,

  /// Rive animations.
  rive,
}

/// One card on the landing screen.
class PreviewSection {
  /// Creates a section for [type].
  const PreviewSection({
    required this.type,
    required this.title,
    required this.description,
  });

  /// Collections shown on the landing screen, in display order.
  static const List<PreviewSection> assetsList = <PreviewSection>[
    PreviewSection(
      type: PreviewSectionType.widgets,
      title: PreviewHubStrings.sectionWidgetsTitle,
      description: PreviewHubStrings.sectionWidgetsDescription,
    ),
    PreviewSection(
      type: PreviewSectionType.iconsAndImages,
      title: PreviewHubStrings.sectionIconsAndImagesTitle,
      description: PreviewHubStrings.sectionIconsAndImagesDescription,
    ),
    PreviewSection(
      type: PreviewSectionType.fonts,
      title: PreviewHubStrings.sectionFontsTitle,
      description: PreviewHubStrings.sectionFontsDescription,
    ),
    PreviewSection(
      type: PreviewSectionType.lottie,
      title: PreviewHubStrings.sectionLottieTitle,
      description: PreviewHubStrings.sectionLottieDescription,
    ),
    PreviewSection(
      type: PreviewSectionType.rive,
      title: PreviewHubStrings.sectionRiveTitle,
      description: PreviewHubStrings.sectionRiveDescription,
    ),
  ];

  /// Collection this card opens.
  final PreviewSectionType type;

  /// Label on the card.
  final String title;

  /// One-line summary under the label.
  final String description;
}

/// Visual identity of a section: its badge icon and accent gradient.
class PreviewSectionStyle {
  /// Creates a style with an [icon] and a two-stop accent.
  const PreviewSectionStyle({
    required this.icon,
    required this.accentStart,
    required this.accentEnd,
  });

  /// Glyph shown inside the badge.
  final IconData icon;

  /// First accent stop, also used for tints and ripples.
  final Color accentStart;

  /// Second accent stop.
  final Color accentEnd;

  /// Gradient painted behind the badge.
  LinearGradient get gradient => LinearGradient(
    colors: <Color>[accentStart, accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Style bound to [type].
  static PreviewSectionStyle of(PreviewSectionType type) => switch (type) {
    PreviewSectionType.widgets => const PreviewSectionStyle(
      icon: Icons.widgets_rounded,
      accentStart: Color(0xFF0EA5E9),
      accentEnd: Color(0xFF6366F1),
    ),
    PreviewSectionType.iconsAndImages => const PreviewSectionStyle(
      icon: Icons.photo_library_rounded,
      accentStart: Color(0xFF6366F1),
      accentEnd: Color(0xFF8B5CF6),
    ),
    PreviewSectionType.fonts => const PreviewSectionStyle(
      icon: Icons.text_fields_rounded,
      accentStart: Color(0xFFF59E0B),
      accentEnd: Color(0xFFF97316),
    ),
    PreviewSectionType.lottie => const PreviewSectionStyle(
      icon: Icons.animation_rounded,
      accentStart: Color(0xFFEC4899),
      accentEnd: Color(0xFFF43F5E),
    ),
    PreviewSectionType.rive => const PreviewSectionStyle(
      icon: Icons.auto_awesome_motion_rounded,
      accentStart: Color(0xFF14B8A6),
      accentEnd: Color(0xFF06B6D4),
    ),
  };
}
