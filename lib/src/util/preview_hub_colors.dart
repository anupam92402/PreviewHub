import 'package:flutter/painting.dart';

/// Every fixed colour the gallery paints with, in one place. Colours that
/// follow the host theme come from the `ColorScheme` instead.
class PreviewHubColors {
  const PreviewHubColors._();

  /// Sky blue: the Widgets gradient, PNG files and JSON files.
  static const Color sky = Color(0xFF0EA5E9);

  /// Indigo: the gallery's seed colour and the Icons & Images gradient.
  static const Color indigo = Color(0xFF6366F1);

  /// Deeper indigo filling a selected `All` filter chip.
  static const Color indigoDeep = Color(0xFF4F5BD5);

  /// Violet: WebP files, audio files and the Icons & Images gradient.
  static const Color violet = Color(0xFF8B5CF6);

  /// Amber: JPEG files and the Fonts gradient.
  static const Color amber = Color(0xFFF59E0B);

  /// Orange: PDF files and the Fonts gradient.
  static const Color orange = Color(0xFFF97316);

  /// Pink: GIF files and the Lottie gradient.
  static const Color pink = Color(0xFFEC4899);

  /// Rose: the Lottie gradient.
  static const Color rose = Color(0xFFF43F5E);

  /// Teal: the Rive gradient.
  static const Color teal = Color(0xFF14B8A6);

  /// Cyan: the Rive gradient.
  static const Color cyan = Color(0xFF06B6D4);

  /// Slate: unknown files and the Other gradient.
  static const Color slate = Color(0xFF64748B);

  /// Light slate: the Other gradient.
  static const Color slateLight = Color(0xFF94A3B8);

  /// Emerald: SVG files and a clean validation report.
  static const Color emerald = Color(0xFF10B981);

  /// Red: video files.
  static const Color red = Color(0xFFEF4444);

  /// Near-black ink offered as an artwork tint.
  static const Color tintInk = Color(0xFF111827);

  /// White offered as an artwork tint, and the light backdrops.
  static const Color white = Color(0xFFFFFFFF);

  /// Blue offered as an artwork tint.
  static const Color tintBlue = Color(0xFF2563EB);

  /// Red offered as an artwork tint.
  static const Color tintRed = Color(0xFFDC2626);

  /// Green offered as an artwork tint.
  static const Color tintGreen = Color(0xFF16A34A);

  /// Amber offered as an artwork tint.
  static const Color tintAmber = Color(0xFFD97706);

  /// The dark preview backdrop.
  static const Color backdropDark = Color(0xFF111318);

  /// Grey squares of the checkerboard backdrop.
  static const Color checkerGrey = Color(0xFFE3E5EA);
}
