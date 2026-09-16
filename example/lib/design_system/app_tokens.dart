import 'package:flutter/material.dart';

/// Colours and measurements shared by every component in this sample design
/// system. Values are spelled out rather than derived, so a preview label such
/// as `filled · large (52)` quotes the same number the widget uses.
class AppTokens {
  const AppTokens._();

  /// Brand colour, used by primary actions.
  static const Color primary = Color(0xFF2563EB);

  /// Tint behind a soft primary surface.
  static const Color primarySoft = Color(0xFFEFF4FE);

  /// Muted slate, used by secondary actions.
  static const Color secondary = Color(0xFF475569);

  /// Tint behind a soft secondary surface.
  static const Color secondarySoft = Color(0xFFF1F4F8);

  /// Teal accent, used by tertiary actions.
  static const Color tertiary = Color(0xFF0F9D8C);

  /// Tint behind a soft tertiary surface.
  static const Color tertiarySoft = Color(0xFFEAF7F5);

  /// Positive state: a completed action.
  static const Color success = Color(0xFF16A34A);

  /// Tint behind a success surface.
  static const Color successSoft = Color(0xFFE9F7EE);

  /// Negative state: a rejected or failed action.
  static const Color failure = Color(0xFFDC2626);

  /// Tint behind a failure surface.
  static const Color failureSoft = Color(0xFFFDECEC);

  /// Waiting state: an action still in flight.
  static const Color pending = Color(0xFFD97706);

  /// Tint behind a pending surface.
  static const Color pendingSoft = Color(0xFFFEF4E6);

  /// Fill of a control that cannot be interacted with.
  static const Color disabledFill = Color(0xFFD7D9DE);

  /// Text and icons inside a disabled control.
  static const Color disabledContent = Color(0xFF9AA0A6);

  /// Border of a disabled outlined control.
  static const Color disabledOutline = Color(0xFFCBD0D6);

  /// Content drawn on top of an accent fill.
  static const Color onAccent = Color(0xFFFFFFFF);

  /// Primary body text.
  static const Color ink = Color(0xFF111827);

  /// Secondary body text, captions and helper lines.
  static const Color inkMuted = Color(0xFF6B7280);

  /// Hairline borders and dividers.
  static const Color outline = Color(0xFFDDE1E7);

  /// Page background behind cards.
  static const Color canvas = Color(0xFFF4F5F7);

  /// Card and field background.
  static const Color surface = Color(0xFFFFFFFF);

  /// Corner radius shared by buttons, fields and cards.
  static const double radius = 12;

  /// Corner radius for small controls such as the checkbox box.
  static const double radiusSmall = 6;

  /// Gradient used by display headings.
  static const LinearGradient brandGradient = LinearGradient(
    colors: <Color>[Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFFDB2777)],
  );

  /// Gradient used by success headings.
  static const LinearGradient successGradient = LinearGradient(
    colors: <Color>[Color(0xFF16A34A), Color(0xFF0F9D8C)],
  );
}
