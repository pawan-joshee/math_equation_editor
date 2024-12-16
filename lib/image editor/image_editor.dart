import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_equation_editor/image%20editor/drawing_painter.dart';
import 'package:math_equation_editor/widgets/custom_color_picker.dart';

import '../bloc/image_editor/image_editor_bloc.dart';
import '../models/edit_history.dart';
import 'crop_overlay.dart';
import 'filters_constants.dart';
import 'models/image_editor_models.dart';

class ImageEditor extends StatelessWidget {
  final String imageUrl;

  const ImageEditor({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImageEditorBloc(),
      child: BlocBuilder<ImageEditorBloc, ImageEditorState>(
        builder: (context, state) {
          return Stack(
            children: [
              _buildMainCanvas(context),
              _buildControls(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainCanvas(BuildContext context) {
    return InteractiveViewer(
      onInteractionUpdate: (details) {
        context.read<ImageEditorBloc>().add(
              UpdateTransformEvent(
                  transform: Matrix4.identity()..scale(details.scale)),
            );
      },
      child: ImageEditorView(
        imageUrl: imageUrl,
      ),
    );
  }

  Widget _buildControls() {
    return Container();
  }
}

class ImageEditorView extends StatefulWidget {
  final String imageUrl;

  const ImageEditorView({
    super.key,
    required this.imageUrl,
  });

  @override
  State<ImageEditorView> createState() => _ImageEditorState();
}

// Add command pattern for undo/redo
abstract class EditCommand {
  void execute();
  void undo();
}

class ImageEditorCommand implements EditCommand {
  final Function doAction;
  final Function undoAction;

  ImageEditorCommand(this.doAction, this.undoAction);

  @override
  void execute() => doAction();

  @override
  void undo() => undoAction();
}

// Add this class at the top level
class CheckerboardPainter extends CustomPainter {
  final int squares;
  final Color color1;
  final Color color2;

  CheckerboardPainter({
    this.squares = 10,
    this.color1 = const Color(0xFFFFFFFF),
    this.color2 = const Color(0xFFCCCCCC),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final squareSize = size.width / squares;

    for (int i = 0; i < squares; i++) {
      for (int j = 0; j < squares; j++) {
        paint.color = (i + j) % 2 == 0 ? color1 : color2;
        canvas.drawRect(
          Rect.fromLTWH(
            i * squareSize,
            j * squareSize,
            squareSize,
            squareSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CheckerboardPainter oldDelegate) => false;
}

class _ImageEditorState extends State<ImageEditorView> {
  double _rotation = 0.0;
  bool _isFlippedHorizontally = false;
  bool _isFlippedVertically = false;
  double _aspectRatio = 1.0;

  late final TransformationController _transformationController;
  final List<CustomEditableText> _textElements = [];
  final List<Offset> _cropPoints = [];

  EditingMode _currentMode = EditingMode.transform;
  Color _drawingColor = Colors.red;
  double _drawingThickness = 5.0;
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _hue = 0.0;
  double _sepia = 0.0;
  double _blur = 0.0;

  List<double> _colorMatrix = [];

  final GlobalKey _canvasKey = GlobalKey();

  final List<DrawingPoint?> _drawingPoints = [];

  final List<List<DrawingPoint?>> _drawingHistory = [];

  final TextEditingController _textController = TextEditingController();
  double _textSize = 20.0;
  Color _textColor = Colors.black;

  final List<EditableSticker> _stickers = [];

  final ValueNotifier<Matrix4> _transformNotifier =
      ValueNotifier(Matrix4.identity());

  final ValueNotifier<Rect> _cropRect = ValueNotifier(Rect.zero);

  CustomEditableText? _selectedText;
  FontWeight _fontWeight = FontWeight.normal;
  FontStyle _fontStyle = FontStyle.normal;
  TextAlign _textAlign = TextAlign.left;

  // Add to existing state variables
  final List<EditCommand> _commandHistory = [];
  int _currentCommandIndex = -1;

  // Add missing fields
  final List<Rect> _cropHistory = [];
  final Rect _previousCrop = Rect.zero;

  // Remove unused field
  // int _historyIndex = -1; // Removed

  // Add command history fields to state
  final List<EditCommand> commandHistory = [];
  int currentCommandIndex = -1;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    _colorMatrix = [
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, 1, 0
    ];

    _cropPoints.addAll([
      const Offset(0, 0),
      const Offset(1, 0),
      const Offset(1, 1),
      const Offset(0, 1),
    ]);
  }

  @override
  void dispose() {
    _transformNotifier.dispose();
    _transformationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageEditorBloc, ImageEditorState>(
      builder: (context, state) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: _buildAppBar(),
            body: ValueListenableBuilder<Matrix4>(
              valueListenable: _transformNotifier,
              builder: (context, matrix, child) {
                return Row(
                  children: [
                    _buildToolbar(),
                    Expanded(
                      child: _buildMainEditor(),
                    ),
                    _buildPropertyPanel(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Image Editor - Not Fully Workable  β'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: _undo,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: _redo,
        ),
        TextButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Save'),
          onPressed: _saveImage,
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      width: 60,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children:
            EditingMode.values.map((mode) => _buildToolbarItem(mode)).toList(),
      ),
    );
  }

  Widget _buildToolbarItem(EditingMode mode) {
    final isSelected = _currentMode == mode;
    return Tooltip(
      message: mode.toString().split('.').last,
      child: InkWell(
        onTap: () => setState(() => _currentMode = mode),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.2)
                : null,
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
          ),
          child: Icon(_getIconForMode(mode)),
        ),
      ),
    );
  }

  Widget _buildPropertyPanel() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: _buildPropertiesForCurrentMode(),
    );
  }

  Widget _buildPropertiesForCurrentMode() {
    switch (_currentMode) {
      case EditingMode.adjust:
        return _buildAdjustmentControls();
      case EditingMode.filter:
        return _buildFilterControls();
      case EditingMode.draw:
        return _buildDrawingControls();
      case EditingMode.text:
        return _buildTextControls();
      case EditingMode.sticker:
        return _buildStickerControls();
      case EditingMode.transform:
        return _buildTransformControls();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMainEditor() {
    return BlocBuilder<ImageEditorBloc, ImageEditorState>(
      builder: (context, state) {
        return Stack(
          children: [
            // Checkerboard background
            CustomPaint(
              painter: CheckerboardPainter(),
              size: Size.infinite,
            ),
            Center(
              // Center the image
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  onInteractionUpdate: (details) {
                    _transformNotifier.value = _transformationController.value;
                  },
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..rotateZ(_rotation)
                        ..scale(
                          _isFlippedHorizontally ? -1.0 : 1.0,
                          _isFlippedVertically ? -1.0 : 1.0,
                        ),
                      alignment: Alignment.center,
                      child: ColorFiltered(
                        colorFilter:
                            ColorFilter.matrix(_calculateColorMatrix()),
                        child: ImageFiltered(
                          imageFilter:
                              ui.ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_currentMode == EditingMode.draw)
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: DrawingPainter(
                      drawingPoints: _drawingPoints,
                      currentStroke: const [],
                      drawingColor: _drawingColor,
                      strokeWidth: _drawingThickness,
                    ),
                  ),
                ),
              ),
            if (_currentMode == EditingMode.crop)
              Positioned.fill(
                child: _buildEnhancedCropOverlay(),
              ),
            if (_currentMode == EditingMode.text) _buildTextOverlay(),
            if (_currentMode == EditingMode.sticker) _buildStickerOverlay(),
            if (_currentMode == EditingMode.crop) _buildCropOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildDrawingLayer(BuildContext context) {
    return BlocBuilder<ImageEditorBloc, ImageEditorState>(
      builder: (context, state) {
        return GestureDetector(
          onPanStart: (details) {
            final renderBox = context.findRenderObject() as RenderBox;
            final point = renderBox.globalToLocal(details.globalPosition);
            context.read<ImageEditorBloc>().add(StartDrawingEvent(point));
            _addCommand(ImageEditorCommand(
              () =>
                  context.read<ImageEditorBloc>().add(StartDrawingEvent(point)),
              () =>
                  context.read<ImageEditorBloc>().add(const DrawingUndoEvent()),
            ));
          },
          onPanUpdate: (details) {
            final renderBox = context.findRenderObject() as RenderBox;
            final point = renderBox.globalToLocal(details.globalPosition);
            context.read<ImageEditorBloc>().add(UpdateDrawingEvent(point));
          },
          onPanEnd: (details) {
            context.read<ImageEditorBloc>().add(EndDrawingEvent());
            _addCommand(ImageEditorCommand(
              () => context.read<ImageEditorBloc>().add(EndDrawingEvent()),
              () => context
                  .read<ImageEditorBloc>()
                  .add(const DrawingEndUndoEvent()),
            ));
          },
          child: CustomPaint(
            painter: DrawingPainter(
              drawingPoints: _drawingPoints,
              currentStroke: const [],
              drawingColor: _drawingColor,
              strokeWidth: _drawingThickness,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final point = renderBox.globalToLocal(details.globalPosition);
    setState(() {
      _drawingPoints.add(
        DrawingPoint(
          paint: Paint()
            ..color = _drawingColor
            ..strokeWidth = _drawingThickness
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke,
          point: point,
        ),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final point = renderBox.globalToLocal(details.globalPosition);

    context.read<ImageEditorBloc>().add(UpdateDrawingEvent(point));
  }

  void _onPanEnd(DragEndDetails details) {
    _drawingPoints.add(null);
    setState(() {
      _drawingHistory.add(List.from(_drawingPoints));
    });
  }

  Widget _buildTextOverlay() {
    return Stack(
      children: _textElements.map((textElement) {
        return Positioned(
          left: textElement.position.dx,
          top: textElement.position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                textElement.position += details.delta;
              });
            },
            onTap: () {
              setState(() {
                _selectedText = textElement;
                _fontWeight = textElement.style.fontWeight ?? FontWeight.normal;
                _fontStyle = textElement.style.fontStyle ?? FontStyle.normal;
              });
              _editText(textElement);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                textElement.text,
                style: textElement.style,
                textAlign: _textAlign,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStickerOverlay() {
    return Stack(
      children: [
        for (var sticker in _stickers)
          Positioned(
            left: sticker.position.dx,
            top: sticker.position.dy,
            child: GestureDetector(
              onScaleStart: (details) {
                sticker.initialFocalPoint = details.focalPoint;
                sticker.initialPosition = sticker.position;
                sticker.initialScale = sticker.scale;
                sticker.initialRotation = sticker.rotation;
              },
              onScaleUpdate: (details) {
                setState(() {
                  final Offset delta =
                      details.focalPoint - sticker.initialFocalPoint;
                  sticker.position = sticker.initialPosition + delta;

                  sticker.scale = sticker.initialScale * details.scale;
                  sticker.rotation = sticker.initialRotation + details.rotation;
                });
              },
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(
                      -sticker.stickerWidth / 2, -sticker.stickerHeight / 2)
                  ..translate(
                      sticker.stickerWidth / 2, sticker.stickerHeight / 2)
                  ..rotateZ(sticker.rotation)
                  ..scale(sticker.scale)
                  ..translate(
                      -sticker.stickerWidth / 2, -sticker.stickerHeight / 2),
                child: sticker.sticker,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCropOverlay() {
    return Stack(
      children: [
        // Darkened overlay
        Container(
          color: Colors.black54,
        ),
        CropOverlay(
          aspectRatio: _aspectRatio,
          onCropRectUpdate: (rect) {
            setState(() => _cropRect.value = rect);
          },
          overlayColor: Colors.black54,
          handleColor: Theme.of(context).primaryColor,
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _lastCrop,
                child: const Text('Last Crop'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _makeCropChanges,
                child: const Text('Make Changes'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _lastCrop() {
    if (_cropHistory.isNotEmpty) {
      final lastCrop = _cropHistory.removeLast();
      setState(() {
        _cropRect.value = lastCrop;
      });
      _addCommand(ImageEditorCommand(
        () => setState(() => _cropRect.value = lastCrop),
        () => setState(() => _cropRect.value = _previousCrop),
      ));
    }
  }

  void _makeCropChanges() {
    // Apply the current crop
    _addCommand(ImageEditorCommand(
      () => _applyCurrentCrop(),
      () => _undoCrop(),
    ));
  }

  void _applyCurrentCrop() {
    // Implement crop application logic
    setState(() {
      // ...existing cropping logic...
    });
  }

  void _undoCrop() {
    // Implement undo crop logic
    if (_cropHistory.isNotEmpty) {
      final previousCrop = _cropHistory.removeLast();
      setState(() {
        _cropRect.value = previousCrop;
      });
    }
  }

  Widget _buildEnhancedCropOverlay() {
    return Stack(
      children: [
        Container(color: Colors.black54),
        ValueListenableBuilder<Rect>(
          valueListenable: _cropRect,
          builder: (context, rect, child) {
            return CustomPaint(
              painter: CropOverlayPainter(
                cropRect: rect,
                aspectRatio: _aspectRatio,
              ),
              child: GestureDetector(
                onPanStart: _handleCropStart,
                onPanUpdate: _handleCropUpdate,
                behavior: HitTestBehavior.translucent,
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleCropStart(DragStartDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    // Store the initial crop position
    setState(() {
      _cropRect.value = Rect.fromPoints(localPosition, localPosition);
    });

    _createUndoableAction(
      EditingMode.crop,
      ActionType.crop,
      _cropRect.value,
      Rect.fromPoints(localPosition, localPosition),
    );
  }

  void _handleCropUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    setState(() {
      // Update the crop rect while maintaining aspect ratio if needed
      final newRect = Rect.fromPoints(_cropRect.value.topLeft, localPosition);
      if (_aspectRatio != 1.0) {
        final width = newRect.width;
        final height = width / _aspectRatio;
        _cropRect.value = Rect.fromLTWH(
          newRect.left,
          newRect.top,
          width,
          height,
        );
      } else {
        _cropRect.value = newRect;
      }
    });
  }

  Widget _buildAdjustmentControls() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAdjustmentSlider(
              'Brightness',
              _brightness,
              -1.0,
              1.0,
              (value) => setState(() {
                    _brightness = value;
                    _updateColorMatrix();
                  })),
          _buildAdjustmentSlider('Contrast', _contrast, 0.0, 2.0,
              (value) => setState(() => _contrast = value)),
          _buildAdjustmentSlider('Saturation', _saturation, 0.0, 2.0,
              (value) => setState(() => _saturation = value)),
          _buildAdjustmentSlider('Hue', _hue, -180.0, 180.0,
              (value) => setState(() => _hue = value)),
          _buildAdjustmentSlider('Sepia', _sepia, 0.0, 1.0,
              (value) => setState(() => _sepia = value)),
          _buildAdjustmentSlider('Blur', _blur, 0.0, 10.0,
              (value) => setState(() => _blur = value)),
        ],
      ),
    );
  }

  Widget _buildAdjustmentSlider(String label, double value, double min,
      double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return ListView(
      children: FiltersConstants.filters.entries.map((entry) {
        return ListTile(
          title: Text(entry.key),
          onTap: () => _applyFilter(entry.value),
        );
      }).toList(),
    );
  }

  Widget _buildDrawingControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Drawing Tools'),
        const SizedBox(height: 16),
        Row(
          children: [
            ColorPicker(
              color: _drawingColor,
              onColorChanged: (color) => setState(() => _drawingColor = color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                value: _drawingThickness,
                min: 1,
                max: 20,
                onChanged: (value) => setState(() => _drawingThickness = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextControls() {
    return Column(
      children: [
        TextField(
          controller: _textController,
          decoration: const InputDecoration(labelText: 'Enter text'),
          onChanged: (value) {
            if (_selectedText != null) {
              setState(() {
                _selectedText!.text = value;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        _buildTextStyleControls(),
        ElevatedButton(
          onPressed: _addText,
          child: const Text('Add Text'),
        ),
      ],
    );
  }

  Widget _buildTextStyleControls() {
    return Wrap(
      spacing: 8,
      children: [
        IconButton(
          icon: const Icon(Icons.format_bold),
          onPressed: _toggleBold,
        ),
        IconButton(
          icon: const Icon(Icons.format_italic),
          onPressed: _toggleItalic,
        ),
        IconButton(
          icon: const Icon(Icons.format_align_left),
          onPressed: () => _setTextAlignment(TextAlign.left),
        ),
        IconButton(
          icon: const Icon(Icons.format_align_center),
          onPressed: () => _setTextAlignment(TextAlign.center),
        ),
        IconButton(
          icon: const Icon(Icons.format_align_right),
          onPressed: () => _setTextAlignment(TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildStickerControls() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _addSticker,
          child: const Text('Add Sticker'),
        ),
      ],
    );
  }

  Widget _buildTransformControls() {
    return Column(
      children: [
        _buildRotationControl(),
        _buildFlipControls(),
        _buildAspectRatioControl(),
      ],
    );
  }

  Widget _buildRotationControl() {
    return Column(
      children: [
        const Text('Rotation'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.rotate_left),
              onPressed: () => setState(() => _rotation -= pi / 2),
            ),
            Expanded(
              child: Slider(
                value: _rotation,
                min: -pi,
                max: pi,
                onChanged: (value) => setState(() => _rotation = value),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.rotate_right),
              onPressed: () => setState(() => _rotation += pi / 2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlipControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.flip),
          onPressed: () =>
              setState(() => _isFlippedHorizontally = !_isFlippedHorizontally),
        ),
        IconButton(
          icon: const Icon(Icons.flip_camera_android),
          onPressed: () =>
              setState(() => _isFlippedVertically = !_isFlippedVertically),
        ),
      ],
    );
  }

  Widget _buildAspectRatioControl() {
    return DropdownButton<double>(
      value: _aspectRatio,
      items: const [
        DropdownMenuItem(value: 1.0, child: Text('1:1')),
        DropdownMenuItem(value: 4 / 3, child: Text('4:3')),
        DropdownMenuItem(value: 16 / 9, child: Text('16:9')),
        DropdownMenuItem(value: 2 / 3, child: Text('2:3')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _aspectRatio = value);
        }
      },
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: CustomColorPicker(
            initialColor: currentColor,
            onColorSelected: (color) => onColorChanged(color),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addText() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _textElements.add(
          CustomEditableText(
            text: _textController.text,
            position: const Offset(100, 100),
            style: TextStyle(
              fontSize: _textSize,
              color: _textColor,
            ),
          ),
        );
        _textController.clear();
      });
    }
  }

  void _addSticker() {
    setState(() {
      _stickers.add(
        EditableSticker(
          sticker: const Icon(Icons.star, size: 50, color: Colors.yellow),
          position: const Offset(100, 100),
        ),
      );
    });
  }

  void _undo() {
    if (_currentCommandIndex >= 0) {
      _commandHistory[_currentCommandIndex].undo();
      _currentCommandIndex--;
    }
  }

  void _redo() {
    if (_currentCommandIndex < _commandHistory.length - 1) {
      _currentCommandIndex++;
      _commandHistory[_currentCommandIndex].execute();
    }
  }

  // Define the _addCommand method
  void _addCommand(EditCommand command) {
    setState(() {
      // Remove any commands after current index
      if (currentCommandIndex < commandHistory.length - 1) {
        commandHistory.removeRange(
            currentCommandIndex + 1, commandHistory.length);
      }

      commandHistory.add(command);
      currentCommandIndex++;
      command.execute();
    });
  }

  // Replace existing save method
  Future<void> _saveImage() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      _showProcessingDialog();

      // Capture the image with all modifications
      final boundary = _canvasKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);

      // Apply crop if needed
      final processedImage =
          _currentMode == EditingMode.crop ? await _cropImage(image) : image;

      // Convert to bytes
      final byteData =
          await processedImage.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Here you can:
      // 1. Save to device gallery
      // 2. Upload to server
      // 3. Share the image
      // 4. Return the bytes to the caller

      navigator.pop(); // Dismiss processing dialog
      await _saveToGallery(pngBytes);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Image saved to gallery')),
      );
    } catch (e) {
      navigator.pop(); // Dismiss processing dialog
      _showErrorDialog('Failed to save image: $e');
    }
  }

  Future<void> _saveToGallery(Uint8List imageBytes) async {
    try {
      // Convert the image bytes to base64
      final base64Image = base64Encode(imageBytes);
      final dataUrl = 'data:image/png;base64,$base64Image';

      // Create a download link
      final anchor = html.AnchorElement(href: dataUrl)
        ..setAttribute(
            'download', 'equation_${DateTime.now().millisecondsSinceEpoch}.png')
        ..style.display = 'none';

      html.document.body!.children.add(anchor);
      anchor.click();
      anchor.remove();
      // Implement save to gallery using image_gallery_saver package
      // await ImageGallerySaver.saveImage(imageBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to gallery')),
      );
    } catch (e) {
      _showErrorDialog('Failed to save to gallery: $e');
    }
  }

  Future<ui.Image> _cropImage(ui.Image source) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    // Calculate crop dimensions
    final rect = _cropRect.value;

    // Draw only the cropped portion
    canvas.drawImageRect(
      source,
      rect,
      Rect.fromLTWH(0, 0, rect.width, rect.height),
      paint,
    );

    return recorder.endRecording().toImage(
          rect.width.toInt(),
          rect.height.toInt(),
        );
  }

  // Add error handling dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Add processing indicator
  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  IconData _getIconForMode(EditingMode mode) {
    switch (mode) {
      case EditingMode.transform:
        return Icons.transform;
      case EditingMode.filter:
        return Icons.filter;
      case EditingMode.adjust:
        return Icons.tune;
      case EditingMode.draw:
        return Icons.brush;
      case EditingMode.text:
        return Icons.text_fields;
      case EditingMode.crop:
        return Icons.crop;
      case EditingMode.sticker:
        return Icons.emoji_emotions;
    }
  }

  void _applyFilter(List<double> matrix) {
    setState(() {
      _colorMatrix = matrix;
    });
  }

  List<double> _calculateColorMatrix() {
    List<double> matrix =
        List<double>.from(FiltersConstants.filters['Normal']!);

    if (_colorMatrix.isNotEmpty &&
        _colorMatrix != FiltersConstants.filters['Normal']) {
      matrix = _multiplyColorMatrices(matrix, _colorMatrix);
    }

    final adjustments = [
      _brightnessMatrix(_brightness),
      _contrastMatrix(_contrast),
      _saturationMatrix(_saturation),
      _hueRotationMatrix(_hue),
      _sepiaMatrix(_sepia),
    ];

    for (var adjustment in adjustments) {
      matrix = _multiplyColorMatrices(matrix, adjustment);
    }

    return matrix;
  }

  List<double> _multiplyColorMatrices(List<double> a, List<double> b) {
    List<double> result = List<double>.filled(20, 0);

    for (int i = 0; i < 4; i++) {
      int index = 5 * i;
      for (int j = 0; j < 5; j++) {
        result[index + j] = b[j] * a[index] +
            b[5 + j] * a[index + 1] +
            b[10 + j] * a[index + 2] +
            b[15 + j] * a[index + 3];
        if (j == 4) result[index + j] += a[index + 4];
      }
    }

    return result;
  }

  void _updateColorMatrix() {
    setState(() {
      final matrix = _calculateColorMatrix();
      _colorMatrix = matrix;
    });
  }

  List<double> _brightnessMatrix(double value) {
    return [
      1 + value,
      0,
      0,
      0,
      0,
      0,
      1 + value,
      0,
      0,
      0,
      0,
      0,
      1 + value,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  List<double> _contrastMatrix(double value) {
    double t = (1.0 - value) / 2.0;
    return [
      value, 0, 0, 0, t, //
      0, value, 0, 0, t, //
      0, 0, value, 0, t, //
      0, 0, 0, 1, 0
    ];
  }

  List<double> _saturationMatrix(double value) {
    const double lumR = 0.3086;
    const double lumG = 0.6094;
    const double lumB = 0.0820;

    double sr = (1 - value) * lumR;
    double sg = (1 - value) * lumG;
    double sb = (1 - value) * lumB;

    return [
      sr + value, sg, sb, 0, 0, //
      sr, sg + value, sb, 0, 0, //
      sr, sg, sb + value, 0, 0, //
      0, 0, 0, 1, 0
    ];
  }

  List<double> _sepiaMatrix(double value) {
    final inv = 1 - value;
    return [
      (inv + value * 0.393), (value * 0.769), (value * 0.189), 0, 0, //
      (value * 0.349), (inv + value * 0.686), (value * 0.168), 0, 0, //
      (value * 0.272), (value * 0.534), (inv + value * 0.131), 0, 0, //
      0, 0, 0, 1, 0
    ];
  }

  List<double> _hueRotationMatrix(double degrees) {
    double radians = degrees * pi / 180;
    double cosVal = cos(radians);
    double sinVal = sin(radians);

    const double lumR = 0.213;
    const double lumG = 0.715;
    const double lumB = 0.072;

    return [
      lumR + cosVal * (1 - lumR) + sinVal * (-lumR),
      lumG + cosVal * (-lumG) + sinVal * (-lumG),
      lumB + cosVal * (-lumB) + sinVal * (1 - lumB),
      0,
      0,
      lumR + cosVal * (-lumR) + sinVal * 0.143,
      lumG + cosVal * (1 - lumG) + sinVal * 0.14,
      lumB + cosVal * (-lumB) + sinVal * (-0.283),
      0,
      0,
      lumR + cosVal * (-lumR) + sinVal * (-(1 - lumR)),
      lumG + cosVal * (-lumG) + sinVal * lumG,
      lumB + cosVal * (1 - lumB) + sinVal * lumB,
      0,
      0,
      0,
      0,
      0,
      1,
      0
    ];
  }

  void _editText(CustomEditableText textElement) {
    _textController.text = textElement.text;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Text'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Size'),
                  Expanded(
                    child: Slider(
                      value: _textSize,
                      min: 10,
                      max: 72,
                      onChanged: (value) {
                        setState(() => _textSize = value);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Color'),
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: () => _showColorPicker(
                      context,
                      _textColor,
                      (color) => setState(() => _textColor = color),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  textElement.text = _textController.text;
                  textElement.style = textElement.style.copyWith(
                    fontSize: _textSize,
                    color: _textColor,
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _toggleBold() {
    if (_selectedText != null) {
      setState(() {
        _fontWeight = _fontWeight == FontWeight.normal
            ? FontWeight.bold
            : FontWeight.normal;
        _selectedText!.style = _selectedText!.style.copyWith(
          fontWeight: _fontWeight,
        );
      });
    }
  }

  void _toggleItalic() {
    if (_selectedText != null) {
      setState(() {
        _fontStyle = _fontStyle == FontStyle.normal
            ? FontStyle.italic
            : FontStyle.normal;
        _selectedText!.style = _selectedText!.style.copyWith(
          fontStyle: _fontStyle,
        );
      });
    }
  }

  void _setTextAlignment(TextAlign alignment) {
    if (_selectedText != null) {
      setState(() {
        _textAlign = alignment;
        _selectedText!.style = _selectedText!.style.copyWith();
      });
    }
  }

  void _createUndoableAction(
      EditingMode mode, ActionType type, dynamic prevState, dynamic newState) {
    final action = EditAction(
      mode: mode,
      type: type,
      previousState: prevState,
      newState: newState,
    );

    context.read<ImageEditorBloc>().add(AddHistoryEvent(action));
  }
}

class ColorPicker extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pick a color'),
            content: SingleChildScrollView(
              child: CustomColorPicker(
                initialColor: color,
                onColorSelected: (color) => onColorChanged(color),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final double aspectRatio;

  CropOverlayPainter({
    required this.cropRect,
    required this.aspectRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw crop rectangle
    canvas.drawRect(cropRect, paint);

    // Draw grid lines
    _drawGrid(canvas, cropRect, paint);

    // Draw corner handles
    _drawCornerHandles(canvas, cropRect, paint);
  }

  void _drawGrid(Canvas canvas, Rect rect, Paint paint) {
    // Draw thirds grid
    final thirdWidth = rect.width / 3;
    final thirdHeight = rect.height / 3;

    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(rect.left + thirdWidth * i, rect.top),
        Offset(rect.left + thirdWidth * i, rect.bottom),
        paint..color = Colors.white.withOpacity(0.5),
      );
      canvas.drawLine(
        Offset(rect.left, rect.top + thirdHeight * i),
        Offset(rect.right, rect.top + thirdHeight * i),
        paint..color = Colors.white.withOpacity(0.5),
      );
    }
  }

  void _drawCornerHandles(Canvas canvas, Rect rect, Paint paint) {
    const handleSize = 20.0;
    paint.color = Colors.white;

    // Draw corner handles
    _drawHandle(canvas, rect.topLeft, handleSize, paint);
    _drawHandle(canvas, rect.topRight, handleSize, paint);
    _drawHandle(canvas, rect.bottomLeft, handleSize, paint);
    _drawHandle(canvas, rect.bottomRight, handleSize, paint);
  }

  void _drawHandle(Canvas canvas, Offset position, double size, Paint paint) {
    canvas.drawCircle(position, size / 4, paint);
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) =>
      oldDelegate.cropRect != cropRect ||
      oldDelegate.aspectRatio != aspectRatio;
}

// Define missing events if not defined elsewhere
// This should ideally be in the ImageEditorBloc file
abstract class ImageEditorEvent {}

class UndoDrawingEvent extends ImageEditorEvent {}

class UndoEndDrawingEvent extends ImageEditorEvent {}
