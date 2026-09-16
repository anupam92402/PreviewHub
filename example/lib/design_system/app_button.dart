import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// How much emphasis a button carries.
enum AppButtonTone {
  /// The single most important action on a screen.
  primary(AppTokens.primary, AppTokens.primarySoft),

  /// A supporting action shown next to a primary one.
  secondary(AppTokens.secondary, AppTokens.secondarySoft),

  /// A low-emphasis action, often destructive-adjacent or optional.
  tertiary(AppTokens.tertiary, AppTokens.tertiarySoft);

  const AppButtonTone(this.accent, this.soft);

  /// Fill of a filled button, and content colour of the other variants.
  final Color accent;

  /// Tint used behind the accent where a soft surface is wanted.
  final Color soft;
}

/// How a button is drawn.
enum AppButtonVariant {
  /// Solid accent fill with white content.
  filled,

  /// Transparent fill inside an accent border.
  outlined,

  /// Accent content with neither fill nor border.
  text,
}

/// Height ramp, named so a preview can quote the number.
enum AppButtonSize {
  /// Compact, for dense rows and inline actions.
  small(36, 14, 13),

  /// The default height.
  medium(44, 18, 14),

  /// Full-width calls to action.
  large(52, 22, 16);

  const AppButtonSize(this.height, this.horizontalPadding, this.fontSize);

  /// Fixed height of the control, in logical pixels.
  final double height;

  /// Padding either side of the content.
  final double horizontalPadding;

  /// Size of the label text.
  final double fontSize;
}

/// The design system's button, in three tones, three variants and three sizes.
/// Passing a null [onPressed] disables the button, which is the only way to
/// reach the disabled styling.
class AppButton extends StatelessWidget {
  /// Creates a button showing [label].
  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.tone = AppButtonTone.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.expand = true,
    super.key,
  });

  /// Words on the button.
  final String label;

  /// Called on tap; null disables the button.
  final VoidCallback? onPressed;

  /// Whether the button is filled, outlined or text-only.
  final AppButtonVariant variant;

  /// How much emphasis the button carries.
  final AppButtonTone tone;

  /// Which height in the ramp to use.
  final AppButtonSize size;

  /// Optional glyph shown before the label.
  final IconData? icon;

  /// Whether the button stretches to the width it is given.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final Color background = switch (variant) {
      AppButtonVariant.filled => enabled ? tone.accent : AppTokens.disabledFill,
      AppButtonVariant.outlined || AppButtonVariant.text => Colors.transparent,
    };
    final Color foreground = switch (variant) {
      AppButtonVariant.filled =>
        enabled ? AppTokens.onAccent : AppTokens.disabledContent,
      AppButtonVariant.outlined || AppButtonVariant.text =>
        enabled ? tone.accent : AppTokens.disabledContent,
    };
    final BorderSide side = variant == AppButtonVariant.outlined
        ? BorderSide(color: enabled ? tone.accent : AppTokens.disabledOutline)
        : BorderSide.none;

    return SizedBox(
      height: size.height,
      width: expand ? double.infinity : null,
      child: Material(
        color: background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          side: side,
        ),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
            child: _AppButtonContent(
              label: label,
              icon: icon,
              foreground: foreground,
              fontSize: size.fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

/// Centred icon and label, sized by the button's place in the ramp.
class _AppButtonContent extends StatelessWidget {
  const _AppButtonContent({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.fontSize,
  });

  final String label;
  final IconData? icon;
  final Color foreground;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      if (icon != null) ...<Widget>[
        Icon(icon, size: fontSize + 4, color: foreground),
        const SizedBox(width: 8),
      ],
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foreground,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
