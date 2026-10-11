import 'package:flutter/material.dart';

/// One line of sample text, optionally with its baseline ruled across it, so
/// families and sizes set side by side can be checked for alignment.
class FontMetricsText extends StatelessWidget {
  /// Sets [text] in [style].
  const FontMetricsText({
    required this.text,
    required this.style,
    required this.showMetrics,
    super.key,
  });

  /// Words to set.
  final String text;

  /// Style to set them in.
  final TextStyle style;

  /// Whether to draw the baseline.
  final bool showMetrics;

  @override
  Widget build(BuildContext context) {
    final Widget line = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    if (!showMetrics) {
      return line;
    }

    return CustomPaint(
      foregroundPainter: _BaselinePainter(
        text: text,
        style: DefaultTextStyle.of(context).style.merge(style),
        textScaler: MediaQuery.textScalerOf(context),
        textDirection: Directionality.of(context),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: line,
    );
  }
}

/// Lays the line out again to learn where its baseline falls, then rules it
/// across the line.
class _BaselinePainter extends CustomPainter {
  const _BaselinePainter({
    required this.text,
    required this.style,
    required this.textScaler,
    required this.textDirection,
    required this.color,
  });

  final String text;

  /// Style the line is drawn in, including any line height the ambient text
  /// style adds, so the baseline lands where the drawn text sits.
  final TextStyle style;

  final TextScaler textScaler;
  final TextDirection textDirection;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout(maxWidth: size.width);
    final LineMetrics? line = painter.computeLineMetrics().firstOrNull;
    painter.dispose();
    if (line == null) {
      return;
    }
    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, line.baseline),
      Offset(size.width, line.baseline),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BaselinePainter oldDelegate) =>
      oldDelegate.text != text ||
      oldDelegate.style != style ||
      oldDelegate.textScaler != textScaler ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.color != color;
}
