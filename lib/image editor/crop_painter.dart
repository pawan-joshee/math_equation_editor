import 'package:flutter/material.dart';

class CropPainter extends CustomPainter {
  final Rect rect;
  final double aspectRatio;

  CropPainter({
    required this.rect,
    required this.aspectRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Draw overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRect(rect),
      ),
      paint,
    );

    // Draw crop rectangle
    paint
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CropPainter oldDelegate) {
    return rect != oldDelegate.rect || aspectRatio != oldDelegate.aspectRatio;
  }
}
