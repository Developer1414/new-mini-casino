import 'dart:math';
import 'package:flutter/material.dart';

class CrashLineCustomPainter extends CustomPainter {
  final double value;
  final Color? color;

  CrashLineCustomPainter(this.value, {this.color});

  static const _whiteColor = Colors.white;
  static const _roundStrokeCap = StrokeCap.round;
  static const _maxLineLengthFactor = 1.8;
  static const _blurRadius = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokePaint = _createStrokePaint(_whiteColor, strokeWidth: 10.0, style: PaintingStyle.stroke, cap: _roundStrokeCap);
    final Paint shadowPaint = _createStrokePaint(Colors.black.withOpacity(0.5), strokeWidth: 10.0, maskFilter: const MaskFilter.blur(BlurStyle.normal, _blurRadius), style: PaintingStyle.stroke, cap: _roundStrokeCap);

    final Path path = Path();
    final double maxLineLength = size.width * _maxLineLengthFactor;
    final double lineLength = maxLineLength * value;
    final double angle = value * (pi / 3.2);
    final double dx = lineLength * cos(angle);
    final double dy = lineLength * sin(angle);

    final double controlX = dx / 2;

    final Paint fillPaint = _createFillPaint(color?? Colors.orange);

    final Path fillPath = Path()..moveTo(0, size.height)..quadraticBezierTo(controlX, size.height, dx, size.height - dy / 1.45)..lineTo(dx, size.height)..lineTo(0, size.height);

    canvas.drawPath(fillPath, fillPaint);

    path.moveTo(0, size.height);
    path.quadraticBezierTo(controlX, size.height, dx, size.height - dy / 1.45);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, strokePaint);

    final Paint circlePaint = _createFillPaint(Colors.white);
    canvas.drawCircle(Offset(dx, size.height - dy / 1.45), 10.0, circlePaint);
  }

  static Paint _createStrokePaint(Color color, {double strokeWidth = 10.0, PaintingStyle style = PaintingStyle.stroke, StrokeCap cap = StrokeCap.round, MaskFilter? maskFilter}) {
    final Paint paint = Paint()
     ..color = color
     ..strokeWidth = strokeWidth
     ..style = style
     ..strokeCap = cap;
    if (maskFilter!= null) {
      paint.maskFilter = maskFilter;
    }
    return paint;
  }

  static Paint _createFillPaint(Color color) {
    final Paint paint = Paint()
     ..color = color
     ..style = PaintingStyle.fill;
    return paint;
  }

  @override
  bool shouldRepaint(CrashLineCustomPainter oldDelegate) {
    return oldDelegate.value!= value;
  }
}
