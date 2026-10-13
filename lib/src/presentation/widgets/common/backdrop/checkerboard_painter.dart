import 'package:flutter/material.dart';

import '../../../../util/preview_hub_colors.dart';

/// Grey squares over the panel's white, so a transparent edge shows.
class CheckerboardPainter extends CustomPainter {
  /// Creates the painter; it holds no state, so it never repaints.
  const CheckerboardPainter();

  /// Side of one square, in logical pixels.
  static const double _cell = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint grey = Paint()..color = PreviewHubColors.checkerGrey;
    for (double y = 0; y < size.height; y += _cell) {
      for (double x = 0; x < size.width; x += _cell) {
        if (((x + y) / _cell).round().isOdd) {
          canvas.drawRect(Rect.fromLTWH(x, y, _cell, _cell), grey);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CheckerboardPainter oldDelegate) => false;
}
