import '../image editor/models/image_editor_models.dart';

enum ActionType { draw, text, transform, filter, adjustment, crop, sticker }

class EditAction {
  final EditingMode mode;
  final ActionType type;
  final dynamic previousState;
  final dynamic newState;
  final DateTime timestamp;

  EditAction({
    required this.mode,
    required this.type,
    required this.previousState,
    required this.newState,
  }) : timestamp = DateTime.now();

  @override
  String toString() => '${type.name} at ${timestamp.toIso8601String()}';
}

class EditHistory {
  final List<EditAction> _actions = [];
  int _currentIndex = -1;

  void addAction(EditAction action) {
    // Remove any actions after current index when new action is added
    if (_currentIndex < _actions.length - 1) {
      _actions.removeRange(_currentIndex + 1, _actions.length);
    }
    _actions.add(action);
    _currentIndex++;
  }

  bool get canUndo => _currentIndex >= 0;
  bool get canRedo => _currentIndex < _actions.length - 1;

  EditAction? undo() {
    if (!canUndo) return null;
    final action = _actions[_currentIndex];
    _currentIndex--;
    return action;
  }

  EditAction? redo() {
    if (!canRedo) return null;
    _currentIndex++;
    return _actions[_currentIndex];
  }

  void clear() {
    _actions.clear();
    _currentIndex = -1;
  }

  List<EditAction> getActions() => List.unmodifiable(_actions);
}
