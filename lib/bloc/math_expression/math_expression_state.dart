part of 'math_expression_bloc.dart';

abstract class MathExpressionState extends Equatable {
  const MathExpressionState();

  bool get canUndo => false;
  bool get canRedo => false;
  String get currentExpression => '';

  @override
  List<Object?> get props => [];
}

class MathExpressionInitial extends MathExpressionState {
  @override
  String get currentExpression => '';
}

class MathExpressionUpdated extends MathExpressionState {
  final String expression;
  final bool hasUndo;
  final bool hasRedo;

  const MathExpressionUpdated(
    this.expression, {
    this.hasUndo = false,
    this.hasRedo = false,
  });

  @override
  String get currentExpression => expression;

  @override
  bool get canUndo => hasUndo;

  @override
  bool get canRedo => hasRedo;

  @override
  List<Object> get props => [expression, hasUndo, hasRedo];
}

class MathExpressionSaved extends MathExpressionState {}

class MathExpressionLoadSuccess extends MathExpressionState {
  final List<String> expressions;

  const MathExpressionLoadSuccess(this.expressions);

  @override
  List<Object> get props => [expressions];
}

class MathExpressionError extends MathExpressionState {
  final String message;

  const MathExpressionError(this.message);

  @override
  List<Object?> get props => [message];
}
