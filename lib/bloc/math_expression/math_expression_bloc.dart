import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'math_expression_event.dart';
part 'math_expression_state.dart';

// math_expression_bloc.dart
class MathExpressionBloc
    extends Bloc<MathExpressionEvent, MathExpressionState> {
  String _currentExpression = '';
  int _undoStackPointer = -1;
  final List<String> _undoStack = [];

  MathExpressionBloc() : super(MathExpressionInitial()) {
    on<UpdateExpression>(_onUpdateExpression);
    on<SetExpression>(_onSetExpression);
    on<ConvertMathML>(_onConvertMathML);
    on<ConvertAsciiMath>(_onConvertAsciiMath);
    on<SaveExpression>(_onSaveExpression);
    on<LoadExpressions>(_onLoadExpressions);
    on<ExportExpression>(_onExportExpression);
    on<UndoExpression>(_onUndoExpression);
    on<RedoExpression>(_onRedoExpression);
    on<DeleteExpression>(_onDeleteExpression); // Add this line
  }

  void _onUpdateExpression(
      UpdateExpression event, Emitter<MathExpressionState> emit) {
    if (event.expression != _currentExpression) {
      _currentExpression = event.expression;
      _addToUndoStack(_currentExpression);
      _emitUpdatedState(emit);
    }
  }

  void _emitUpdatedState(Emitter<MathExpressionState> emit) {
    emit(MathExpressionUpdated(
      _currentExpression,
      hasUndo: _undoStackPointer > 0,
      hasRedo: _undoStackPointer < _undoStack.length - 1,
    ));
  }

  void _onSetExpression(
      SetExpression event, Emitter<MathExpressionState> emit) {
    _currentExpression = event.latex;
    _addToUndoStack(_currentExpression);
    _emitUpdatedState(emit);
  }

  Future<void> _onConvertMathML(
      ConvertMathML event, Emitter<MathExpressionState> emit) async {
    try {
      final latex = await _convertMathMLToLatex(event.mathML);
      if (latex != null) {
        emit(MathExpressionUpdated(latex));
      } else {
        emit(const MathExpressionError('Failed to convert MathML to LaTeX'));
      }
    } catch (e) {
      emit(MathExpressionError('Error converting MathML: $e'));
    }
  }

  Future<void> _onConvertAsciiMath(
      ConvertAsciiMath event, Emitter<MathExpressionState> emit) async {
    try {
      final latex = await _convertAsciiMathToLatex(event.asciiMath);
      if (latex != null) {
        emit(MathExpressionUpdated(latex));
      } else {
        emit(const MathExpressionError('Failed to convert AsciiMath to LaTeX'));
      }
    } catch (e) {
      emit(MathExpressionError('Error converting AsciiMath: $e'));
    }
  }

  String _cleanAndNormalizeMathML(String mathML) {
    // Remove XML declarations and unnecessary whitespace
    return mathML
        .replaceAll(RegExp(r'<\?xml.*?\?>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<String?> _convertMathMLToLatex(String mathML) async {
    try {
      String cleaned = _cleanAndNormalizeMathML(mathML);

      // Basic conversion of common MathML elements
      String latex = cleaned
          .replaceAll('<math>', '')
          .replaceAll('</math>', '')
          .replaceAll('<mrow>', '')
          .replaceAll('</mrow>', '')
          .replaceAll('<mi>', '')
          .replaceAll('</mi>', '')
          .replaceAll('<mo>', '')
          .replaceAll('</mo>', '')
          .replaceAll('<mn>', '')
          .replaceAll('</mn>', '');

      // Convert fractions
      latex =
          latex.replaceAll('<mfrac>', '\\frac{').replaceAll('</mfrac>', '}');

      return latex;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _convertAsciiMathToLatex(String asciiMath) async {
    try {
      // Basic conversion of common ASCII math symbols
      String latex = asciiMath
          .replaceAll('sum', '\\sum')
          .replaceAll('int', '\\int')
          .replaceAll('inf', '\\infty')
          .replaceAll('->', '\\rightarrow')
          .replaceAll('>=', '\\geq')
          .replaceAll('<=', '\\leq');

      return latex;
    } catch (e) {
      return null;
    }
  }

  Future<void> _onSaveExpression(
      SaveExpression event, Emitter<MathExpressionState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? expressions = prefs.getStringList('expressions') ?? [];
    if (_currentExpression.isNotEmpty) {
      expressions.add(_currentExpression);
      await prefs.setStringList('expressions', expressions);
      emit(MathExpressionSaved());
      emit(MathExpressionUpdated(
          _currentExpression)); // Maintain current expression
    }
  }

  Future<void> _onLoadExpressions(
      LoadExpressions event, Emitter<MathExpressionState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? expressions = prefs.getStringList('expressions') ?? [];
    emit(MathExpressionLoadSuccess(expressions));
  }

  void _onExportExpression(
      ExportExpression event, Emitter<MathExpressionState> emit) {
    // Handle export logic here or trigger a separate service
  }

  void _addToUndoStack(String expression) {
    // Clear redo stack when new expression is added
    if (_undoStackPointer < _undoStack.length - 1) {
      _undoStack.removeRange(_undoStackPointer + 1, _undoStack.length);
    }

    if (_undoStack.isEmpty || _undoStack.last != expression) {
      _undoStack.add(expression);
      _undoStackPointer = _undoStack.length - 1;
    }
  }

  void _onUndoExpression(
      UndoExpression event, Emitter<MathExpressionState> emit) {
    if (_undoStackPointer > 0) {
      _undoStackPointer--;
      _currentExpression = _undoStack[_undoStackPointer];
      _emitUpdatedState(emit);
    }
  }

  void _onRedoExpression(
      RedoExpression event, Emitter<MathExpressionState> emit) {
    if (_undoStackPointer < _undoStack.length - 1) {
      _undoStackPointer++;
      _currentExpression = _undoStack[_undoStackPointer];
      _emitUpdatedState(emit);
    }
  }

  Future<void> _onDeleteExpression(
      DeleteExpression event, Emitter<MathExpressionState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? expressions = prefs.getStringList('expressions') ?? [];
    expressions.remove(event.expression);
    await prefs.setStringList('expressions', expressions);
    emit(MathExpressionLoadSuccess(expressions));
  }
}
