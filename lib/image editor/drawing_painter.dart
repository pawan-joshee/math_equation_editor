import 'package:flutter/material.dart';

import 'models/image_editor_models.dart';

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> drawingPoints;
  final List<Offset> currentStroke;
  final Color drawingColor;
  final double strokeWidth;

  DrawingPainter({
    required this.drawingPoints,
    required this.currentStroke,
    required this.drawingColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
        canvas.drawLine(
          drawingPoints[i]!.point,
          drawingPoints[i + 1]!.point,
          drawingPoints[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
