part of 'image_editor_bloc.dart';

abstract class ImageEditorEvent extends Equatable {
  const ImageEditorEvent();

  @override
  List<Object?> get props => [];
}

class ChangeModeEvent extends ImageEditorEvent {
  final EditingMode mode;
  const ChangeModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class StartDrawingEvent extends ImageEditorEvent {
  final Offset point;
  const StartDrawingEvent(this.point);

  @override
  List<Object?> get props => [point];
}

class UpdateDrawingEvent extends ImageEditorEvent {
  final Offset point;
  const UpdateDrawingEvent(this.point);

  @override
  List<Object?> get props => [point];
}

class EndDrawingEvent extends ImageEditorEvent {}

class AddTextEvent extends ImageEditorEvent {
  final CustomEditableText text;
  const AddTextEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class UpdateTransformEvent extends ImageEditorEvent {
  final double? rotation;
  final bool? flipHorizontal;
  final bool? flipVertical;
  final Matrix4? transform;

  const UpdateTransformEvent({
    this.rotation,
    this.flipHorizontal,
    this.flipVertical,
    this.transform,
  });

  @override
  List<Object?> get props =>
      [rotation, flipHorizontal, flipVertical, transform];
}

class ApplyFilterEvent extends ImageEditorEvent {
  final String filterName;
  const ApplyFilterEvent(this.filterName);
}

class UpdateAdjustmentEvent extends ImageEditorEvent {
  final String key;
  final double value;
  const UpdateAdjustmentEvent(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class UndoEvent extends ImageEditorEvent {}

class RedoEvent extends ImageEditorEvent {}

class AddHistoryEvent extends ImageEditorEvent {
  final EditAction action;
  const AddHistoryEvent(this.action);

  @override
  List<Object?> get props => [action];
}

// Update the event classes
class DrawingUndoEvent extends ImageEditorEvent {
  const DrawingUndoEvent();
}

class DrawingEndUndoEvent extends ImageEditorEvent {
  const DrawingEndUndoEvent();
}
