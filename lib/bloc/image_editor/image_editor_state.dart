part of 'image_editor_bloc.dart';

@immutable
class ImageEditorState extends Equatable {
  final EditingMode currentMode;
  final List<DrawingPoint?> drawingPoints;
  final List<DrawingPoint?> currentStroke;
  final Color drawingColor;
  final double strokeWidth;
  final Matrix4 transform;
  final double rotation;
  final bool isFlippedHorizontally;
  final bool isFlippedVertically;
  final List<CustomEditableText> textElements;
  final List<EditableSticker> stickers;
  final Map<String, double> adjustments;
  final List<List<DrawingPoint?>> drawingHistory;
  final int historyIndex;
  final EditorFilter currentFilter;
  final EditHistory editHistory;
  final Rect cropRect;

  ImageEditorState({
    this.currentMode = EditingMode.transform,
    this.drawingPoints = const [],
    this.currentStroke = const [],
    this.drawingColor = Colors.black,
    this.strokeWidth = 5.0,
    Matrix4? transform,
    this.rotation = 0.0,
    this.isFlippedHorizontally = false,
    this.isFlippedVertically = false,
    this.textElements = const [],
    this.stickers = const [],
    this.adjustments = const {
      'brightness': 0.0,
      'contrast': 1.0,
      'saturation': 1.0,
      'hue': 0.0,
      'sepia': 0.0,
      'blur': 0.0,
    },
    this.drawingHistory = const [],
    this.historyIndex = -1,
    EditorFilter? currentFilter,
    EditHistory? editHistory,
    this.cropRect = Rect.zero,
  })  : transform = transform ?? Matrix4.identity(),
        currentFilter = currentFilter ??
            EditorFilter(
              name: 'Normal',
              matrix: EditorFilter.presets['Normal']!,
            ),
        editHistory = editHistory ?? EditHistory();

  @override
  List<Object?> get props => [
        currentMode,
        drawingPoints,
        currentStroke,
        drawingColor,
        strokeWidth,
        transform,
        rotation,
        isFlippedHorizontally,
        isFlippedVertically,
        textElements,
        stickers,
        adjustments,
        drawingHistory,
        historyIndex,
        currentFilter,
        editHistory,
        cropRect,
      ];

  ImageEditorState copyWith({
    EditingMode? currentMode,
    List<DrawingPoint?>? drawingPoints,
    List<DrawingPoint?>? currentStroke,
    Color? drawingColor,
    double? strokeWidth,
    Matrix4? transform,
    double? rotation,
    bool? isFlippedHorizontally,
    bool? isFlippedVertically,
    List<CustomEditableText>? textElements,
    List<EditableSticker>? stickers,
    Map<String, double>? adjustments,
    List<List<DrawingPoint?>>? drawingHistory,
    int? historyIndex,
    EditorFilter? currentFilter,
    EditHistory? editHistory,
    Rect? cropRect,
  }) {
    return ImageEditorState(
      currentMode: currentMode ?? this.currentMode,
      drawingPoints: drawingPoints ?? this.drawingPoints,
      currentStroke: currentStroke ?? this.currentStroke,
      drawingColor: drawingColor ?? this.drawingColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      transform: transform ?? this.transform,
      rotation: rotation ?? this.rotation,
      isFlippedHorizontally:
          isFlippedHorizontally ?? this.isFlippedHorizontally,
      isFlippedVertically: isFlippedVertically ?? this.isFlippedVertically,
      textElements: textElements ?? this.textElements,
      stickers: stickers ?? this.stickers,
      adjustments: adjustments ?? this.adjustments,
      drawingHistory: drawingHistory ?? this.drawingHistory,
      historyIndex: historyIndex ?? this.historyIndex,
      currentFilter: currentFilter ?? this.currentFilter,
      editHistory: editHistory ?? this.editHistory,
      cropRect: cropRect ?? this.cropRect,
    );
  }
}
