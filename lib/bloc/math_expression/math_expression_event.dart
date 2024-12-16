part of 'math_expression_bloc.dart';

abstract class MathExpressionEvent extends Equatable {
  const MathExpressionEvent();

  @override
  List<Object?> get props => [];
}

class UpdateExpression extends MathExpressionEvent {
  final String expression;

  const UpdateExpression(this.expression);

  @override
  List<Object?> get props => [expression];

  @override
  String toString() => 'UpdateExpression: $expression';
}

class SaveExpression extends MathExpressionEvent {}

class LoadExpressions extends MathExpressionEvent {}

class ExportExpression extends MathExpressionEvent {
  final String expression;

  const ExportExpression(this.expression);

  @override
  List<Object?> get props => [expression];
}

class UndoExpression extends MathExpressionEvent {}

class RedoExpression extends MathExpressionEvent {}

class DeleteExpression extends MathExpressionEvent {
  final String expression;

  const DeleteExpression(this.expression);

  @override
  List<Object?> get props => [expression];
}

class SetExpression extends MathExpressionEvent {
  final String latex;

  const SetExpression(this.latex);

  @override
  List<Object?> get props => [latex];
}

class ConvertMathML extends MathExpressionEvent {
  final String mathML;

  const ConvertMathML(this.mathML);

  @override
  List<Object?> get props => [mathML];
}

class ConvertAsciiMath extends MathExpressionEvent {
  final String asciiMath;

  const ConvertAsciiMath(this.asciiMath);

  @override
  List<Object?> get props => [asciiMath];
}
