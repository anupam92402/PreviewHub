import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Text painted with a gradient instead of a flat colour. The shader is masked
/// onto the glyphs, so the gradient spans the laid-out text rather than the
/// whole line box. The text colour must be opaque for `srcIn` to keep the
/// glyphs.
class GradientText extends StatelessWidget {
  /// Creates gradient text showing [text].
  const GradientText(
    this.text, {
    this.gradient = AppTokens.brandGradient,
    this.style,
    this.textAlign,
    this.maxLines,
    super.key,
  });

  /// Words to paint.
  final String text;

  /// Colours swept across the glyphs.
  final Gradient gradient;

  /// Type style; the colour in it is replaced by the gradient.
  final TextStyle? style;

  /// How the text sits within its line box.
  final TextAlign? textAlign;

  /// Lines allowed before the text is ellipsised.
  final int? maxLines;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (Rect bounds) =>
        gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
    child: Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style:
          style ??
          const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: AppTokens.onAccent,
          ),
    ),
  );
}
