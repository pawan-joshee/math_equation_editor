// Add CropOverlay widget
import 'package:flutter/material.dart';

class CropOverlay extends StatefulWidget {
  final double aspectRatio;
  final ValueChanged<Rect> onCropRectUpdate;
  final Color overlayColor;
  final Color handleColor;

  const CropOverlay({
    super.key,
    required this.aspectRatio,
    required this.onCropRectUpdate,
    this.overlayColor = Colors.black54,
    this.handleColor = Colors.white,
  });

  @override
  State<CropOverlay> createState() => _CropOverlayState();
}

class _CropOverlayState extends State<CropOverlay> {
  late Rect _cropRect;
  Size? _imageSize;
  int? activeHandleIndex;

  @override
  void initState() {
    super.initState();
    _cropRect = Rect.zero;
  }

  void _updateCropRect(Size size) {
    if (_imageSize != size) {
      _imageSize = size;
      if (_cropRect == Rect.zero) {
        _initializeCropRect(size);
      }
    }
  }

  void _initializeCropRect(Size size) {
    final imageAspectRatio = size.width / size.height;
    double rectWidth, rectHeight;

    if (widget.aspectRatio > imageAspectRatio) {
      rectWidth = size.width * 0.8;
      rectHeight = rectWidth / widget.aspectRatio;
    } else {
      rectHeight = size.height * 0.8;
      rectWidth = rectHeight * widget.aspectRatio;
    }

    final left = (size.width - rectWidth) / 2;
    final top = (size.height - rectHeight) / 2;

    _cropRect = Rect.fromLTWH(left, top, rectWidth, rectHeight);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCropRectUpdate(_cropRect);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _updateCropRect(Size(constraints.maxWidth, constraints.maxHeight));
        return Stack(
          children: [
            _buildOverlay(),
            _buildCropRect(),
            ..._buildHandles(),
          ],
        );
      },
    );
  }

  Widget _buildOverlay() {
    return CustomPaint(
      size: _imageSize!,
      painter: CropOverlayPainter(
        rect: _cropRect,
        color: widget.overlayColor,
      ),
    );
  }

  Widget _buildCropRect() {
    return Positioned(
      left: _cropRect.left,
      top: _cropRect.top,
      child: GestureDetector(
        onPanUpdate: (details) => _handlePanUpdate(details, -1),
        child: Container(
          width: _cropRect.width,
          height: _cropRect.height,
          decoration: BoxDecoration(
            border: Border.all(color: widget.handleColor, width: 2),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHandles() {
    const handleSize = 20.0;
    const handlePadding = handleSize / 2;
    final handles = <Widget>[];
    final positions = [
      Offset(_cropRect.left - handlePadding, _cropRect.top - handlePadding),
      Offset(_cropRect.right - handlePadding, _cropRect.top - handlePadding),
      Offset(_cropRect.right - handlePadding, _cropRect.bottom - handlePadding),
      Offset(_cropRect.left - handlePadding, _cropRect.bottom - handlePadding),
    ];

    for (var i = 0; i < positions.length; i++) {
      handles.add(
        Positioned(
          left: positions[i].dx,
          top: positions[i].dy,
          child: GestureDetector(
            onPanStart: (_) => activeHandleIndex = i,
            onPanUpdate: (details) => _handlePanUpdate(details, i),
            onPanEnd: (_) => activeHandleIndex = null,
            child: Container(
              width: handleSize,
              height: handleSize,
              decoration: BoxDecoration(
                color: widget.handleColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }

    return handles;
  }

  void _handlePanUpdate(DragUpdateDetails details, int handleIndex) {
    if (_imageSize == null) return;
    setState(() {
      if (handleIndex == -1) {
        // Move entire rectangle
        _cropRect = _cropRect.translate(
          details.delta.dx,
          details.delta.dy,
        );
      } else {
        // Resize from corner
        final delta = details.delta;
        var newRect = _cropRect;

        switch (handleIndex) {
          case 0: // Top-left
            newRect = Rect.fromLTRB(
              _cropRect.left + delta.dx,
              _cropRect.top + delta.dy,
              _cropRect.right,
              _cropRect.bottom,
            );
            break;
          case 1: // Top-right
            newRect = Rect.fromLTRB(
              _cropRect.left,
              _cropRect.top + delta.dy,
              _cropRect.right + delta.dx,
              _cropRect.bottom,
            );
            break;
          case 2: // Bottom-right
            newRect = Rect.fromLTRB(
              _cropRect.left,
              _cropRect.top,
              _cropRect.right + delta.dx,
              _cropRect.bottom + delta.dy,
            );
            break;
          case 3: // Bottom-left
            newRect = Rect.fromLTRB(
              _cropRect.left + delta.dx,
              _cropRect.top,
              _cropRect.right,
              _cropRect.bottom + delta.dy,
            );
            break;
        }

        // Maintain aspect ratio if needed
        if (widget.aspectRatio > 0) {
          newRect = _maintainAspectRatio(newRect, handleIndex);
        }

        _cropRect = _constrainRect(newRect);
      }

      widget.onCropRectUpdate(_cropRect);
    });
  }

  Rect _maintainAspectRatio(Rect rect, int handle) {
    final targetRatio = widget.aspectRatio;
    final currentRatio = rect.width / rect.height;

    if (currentRatio != targetRatio) {
      if (handle == 0 || handle == 2) {
        // Left handles
        final newWidth = rect.height * targetRatio;
        return Rect.fromLTWH(
          rect.left,
          rect.top,
          newWidth,
          rect.height,
        );
      } else {
        // Right handles
        final newHeight = rect.width / targetRatio;
        return Rect.fromLTWH(
          rect.left,
          rect.top,
          rect.width,
          newHeight,
        );
      }
    }
    return rect;
  }

  Rect _constrainRect(Rect rect) {
    if (_imageSize == null) return rect;
    return Rect.fromLTRB(
      rect.left.clamp(0, _imageSize!.width),
      rect.top.clamp(0, _imageSize!.height),
      rect.right.clamp(0, _imageSize!.width),
      rect.bottom.clamp(0, _imageSize!.height),
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect rect;
  final Color color;

  CropOverlayPainter({required this.rect, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw darkened overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(rect),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    return rect != oldDelegate.rect || color != oldDelegate.color;
  }
}
