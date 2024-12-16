import 'dart:math';

import 'package:flutter/material.dart';

enum EditingMode { transform, filter, adjust, draw, text, crop, sticker }

@immutable
class DrawingPoint {
  final Offset point;
  final Paint paint;
  final double thickness;
  final Color color;

  const DrawingPoint({
    required this.point,
    required this.paint,
    this.thickness = 5.0,
    this.color = Colors.black,
  });

  DrawingPoint copyWith({
    Offset? point,
    Paint? paint,
    double? thickness,
    Color? color,
  }) {
    return DrawingPoint(
      point: point ?? this.point,
      paint: paint ?? this.paint,
      thickness: thickness ?? this.thickness,
      color: color ?? this.color,
    );
  }
}

@immutable
class EditorFilter {
  final String name;
  final List<double> matrix;

  const EditorFilter({
    required this.name,
    required this.matrix,
  });

  static const Map<String, List<double>> presets = {
    'Normal': [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
    'Grayscale': [
      0.2126, 0.7152, 0.0722, 0, 0, //
      0.2126, 0.7152, 0.0722, 0, 0, //
      0.2126, 0.7152, 0.0722, 0, 0, //
      0, 0, 0, 1, 0,
    ],
    'Sepia': [
      0.393, 0.769, 0.189, 0, 0, //
      0.349, 0.686, 0.168, 0, 0, //
      0.272, 0.534, 0.131, 0, 0, //
      0, 0, 0, 1, 0,
    ],
    'Invert': [
      -1, 0, 0, 0, 255, //
      0, -1, 0, 0, 255, //
      0, 0, -1, 0, 255, //
      0, 0, 0, 1, 0,
    ],
    'Hue': [
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, 1, 0,
    ],
    'Brightness': [
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, 1, 0,
    ],
    'Contrast': [
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, 1, 0,
    ],
    'Saturation': [
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, 1, 0,
    ],

    // ...add other filter presets
  };
}

class CustomEditableText {
  String text;
  Offset position;
  TextStyle style;

  CustomEditableText({
    required this.text,
    required this.position,
    required this.style,
  });
}

class EditableSticker {
  final Widget sticker;
  Offset position;
  double scale;
  double rotation;

  late Offset initialFocalPoint;
  late Offset initialPosition;
  late double initialScale;
  late double initialRotation;

  final double stickerWidth = 50.0;
  final double stickerHeight = 50.0;

  EditableSticker({
    required this.sticker,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  Offset get center => position + Offset(stickerWidth / 2, stickerHeight / 2);

  void updateFromGesture(ScaleUpdateDetails details) {
    final delta = details.focalPoint - initialFocalPoint;
    position = initialPosition + delta;
    scale = (initialScale * details.scale).clamp(0.5, 3.0);
    rotation = (initialRotation + details.rotation).clamp(-2 * pi, 2 * pi);
  }
}
