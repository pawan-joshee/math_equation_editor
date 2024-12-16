import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../image editor/models/image_editor_models.dart';
import '../../models/edit_history.dart';

part 'image_editor_event.dart';
part 'image_editor_state.dart';

class ImageEditorBloc extends Bloc<ImageEditorEvent, ImageEditorState> {
  final EditHistory _history = EditHistory();

  ImageEditorBloc() : super(ImageEditorState()) {
    on<ChangeModeEvent>(_onChangeMode);
    on<StartDrawingEvent>(_onStartDrawing);
    on<UpdateDrawingEvent>(_onUpdateDrawing);
    on<EndDrawingEvent>(_onEndDrawing);
    on<AddTextEvent>(_onAddText);
    on<UpdateTransformEvent>(_onUpdateTransform);
    on<ApplyFilterEvent>(_onApplyFilter);
    on<UpdateAdjustmentEvent>(_onUpdateAdjustment);
    on<UndoEvent>(_onUndo);
    on<RedoEvent>(_onRedo);
    on<AddHistoryEvent>(_onAddHistory);
  }

  void _onChangeMode(ChangeModeEvent event, Emitter<ImageEditorState> emit) {
    emit(state.copyWith(currentMode: event.mode));
  }

  void _onStartDrawing(
      StartDrawingEvent event, Emitter<ImageEditorState> emit) {
    final point = DrawingPoint(
      point: event.point,
      paint: Paint()
        ..color = state.drawingColor
        ..strokeWidth = state.strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    emit(state.copyWith(
      currentStroke: [point],
    ));
  }

  void _onUpdateDrawing(
      UpdateDrawingEvent event, Emitter<ImageEditorState> emit) {
    final point = DrawingPoint(
      point: event.point,
      paint: Paint()
        ..color = state.drawingColor
        ..strokeWidth = state.strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    emit(state.copyWith(
      currentStroke: [...state.currentStroke, point],
    ));
  }

  void _onEndDrawing(EndDrawingEvent event, Emitter<ImageEditorState> emit) {
    if (state.currentStroke.isEmpty) return;

    final newPoints = List<DrawingPoint?>.from(state.drawingPoints)
      ..addAll(state.currentStroke)
      ..add(null); // To separate strokes

    final newHistory = List<List<DrawingPoint?>>.from(state.drawingHistory)
      ..add(newPoints);

    emit(state.copyWith(
      drawingPoints: newPoints,
      currentStroke: [],
      drawingHistory: newHistory,
      historyIndex: newHistory.length - 1,
    ));
  }

  void _onAddText(AddTextEvent event, Emitter<ImageEditorState> emit) {
    final newTextElements = List<CustomEditableText>.from(state.textElements)
      ..add(event.text);
    emit(state.copyWith(textElements: newTextElements));
  }

  void _onUpdateTransform(
      UpdateTransformEvent event, Emitter<ImageEditorState> emit) {
    emit(state.copyWith(
      rotation: event.rotation ?? state.rotation,
      isFlippedHorizontally:
          event.flipHorizontal ?? state.isFlippedHorizontally,
      isFlippedVertically: event.flipVertical ?? state.isFlippedVertically,
      transform: event.transform ?? state.transform,
    ));
  }

  void _onApplyFilter(ApplyFilterEvent event, Emitter<ImageEditorState> emit) {
    emit(state.copyWith(
      currentFilter: EditorFilter(
        name: event.filterName,
        matrix: EditorFilter.presets[event.filterName]!,
      ),
    ));
  }

  void _onUpdateAdjustment(
      UpdateAdjustmentEvent event, Emitter<ImageEditorState> emit) {
    final newAdjustments = Map<String, double>.from(state.adjustments)
      ..[event.key] = event.value;
    emit(state.copyWith(
      adjustments: newAdjustments,
    ));
  }

  void _onUndo(UndoEvent event, Emitter<ImageEditorState> emit) {
    final action = _history.undo();
    if (action != null) {
      _applyAction(action, emit, isUndo: true);
    }
  }

  void _onRedo(RedoEvent event, Emitter<ImageEditorState> emit) {
    final action = _history.redo();
    if (action != null) {
      _applyAction(action, emit);
    }
  }

  void _onAddHistory(AddHistoryEvent event, Emitter<ImageEditorState> emit) {
    _history.addAction(event.action);
    // Update state based on action type
    _applyAction(event.action, emit);
  }

  void _applyAction(EditAction action, Emitter<ImageEditorState> emit,
      {bool isUndo = false}) {
    final state = isUndo ? action.previousState : action.newState;

    switch (action.type) {
      case ActionType.draw:
        emit(this.state.copyWith(drawingPoints: state as List<DrawingPoint?>));
        break;
      case ActionType.transform:
        emit(this.state.copyWith(transform: state as Matrix4));
        break;
      case ActionType.filter:
        emit(this.state.copyWith(currentFilter: state as EditorFilter));
        break;
      case ActionType.adjustment:
        emit(this.state.copyWith(adjustments: state as Map<String, double>));
        break;
      case ActionType.text:
        emit(this
            .state
            .copyWith(textElements: state as List<CustomEditableText>));
        break;
      case ActionType.crop:
        emit(this.state.copyWith(cropRect: state as Rect));
        break;
      case ActionType.sticker:
        emit(this.state.copyWith(stickers: state as List<EditableSticker>));
        break;
    }
  }
}
