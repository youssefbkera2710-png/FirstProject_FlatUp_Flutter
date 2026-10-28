import 'package:flutter/material.dart';

class StarpainterWidget extends CustomPainter {
  final double fillPercent;
  final Color color;

  StarpainterWidget({required this.fillPercent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path starPath = _createStarPath(size);

    // رسم النجمة الفارغة
    canvas.drawPath(starPath, borderPaint);

    if (fillPercent > 0) {
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(0, 0, size.width * fillPercent, size.height),
      );
      canvas.drawPath(starPath, fillPaint);
      canvas.restore();
    }
  }

  Path _createStarPath(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.5, 0);
    path.lineTo(w * 0.65, h * 0.35);
    path.lineTo(w, h * 0.4);
    path.lineTo(w * 0.75, h * 0.65);
    path.lineTo(w * 0.8, h);
    path.lineTo(w * 0.5, h * 0.8);
    path.lineTo(w * 0.2, h);
    path.lineTo(w * 0.25, h * 0.65);
    path.lineTo(0, h * 0.4);
    path.lineTo(w * 0.35, h * 0.35);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
