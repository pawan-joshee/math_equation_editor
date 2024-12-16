import 'dart:developer';

import 'package:easy_latex/easy_latex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_math_fork/flutter_math.dart' as math_fork;

import '../bloc/math_expression/math_expression_bloc.dart';
import '../bloc/settings/settings_bloc.dart';
import 'types/latex_renderer.dart';
import 'utils/custom_text_decoration.dart';
import 'utils/scalable_brackets.dart';

class RenderedExpression extends StatelessWidget {
  const RenderedExpression({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MathExpressionBloc, MathExpressionState>(
      builder: (context, mathState) {
        final expression = mathState is MathExpressionUpdated
            ? mathState.expression
            : r'{\pi}(\sqrt{\frac{{e}^{2}}{{e}\sqrt{{x}}}})';
        String scalableExpression =
            MakeScalableBrackets.makeScalableBrackets(expression);
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            double fontSize = 40.0; // Default font size
            Color expressionColor = Colors.black;
            Color backgroundColor = Colors.white;
            math_fork.MathStyle mathStyle = math_fork.MathStyle.display;

            // TextStyle properties
            FontWeight fontWeight = FontWeight.normal;
            FontStyle fontStyle = FontStyle.normal;
            TextDecoration textDecoration = TextDecoration.none;

            // Container styling properties
            double containerPadding = 3.0;
            double containerMargin = 3.0;
            Color containerBorderColor = Colors.transparent;
            double containerBorderRadius = 8.0;

            if (settingsState is SettingsLoadSuccess) {
              fontSize = settingsState.settings.fontSize;
              expressionColor = settingsState.settings.expressionColor;
              backgroundColor = settingsState.settings.backgroundColor;
              mathStyle = settingsState.settings.mathStyle;

              fontWeight = settingsState.settings.fontWeight;
              fontStyle = settingsState.settings.fontStyle;
              textDecoration = _mapCustomTextDecorationToTextDecoration(
                  settingsState.settings.textDecoration);

              containerPadding = settingsState.settings.containerPadding;
              containerMargin = settingsState.settings.containerMargin;
              containerBorderColor =
                  settingsState.settings.containerBorderColor;
              containerBorderRadius =
                  settingsState.settings.containerBorderRadius;
            }

            // Handle expression rendering
            Widget mathContent = expression.isEmpty
                ? const Center(
                    child: Text(
                      'Enter expression',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : settingsState is SettingsLoadSuccess &&
                        settingsState.settings.latexRenderer ==
                            LatexRenderer.easyLatex
                    ? _buildEasyLatexExpression(
                        scalableExpression,
                        fontSize,
                        expressionColor,
                      )
                    : _buildMathForkExpression(
                        scalableExpression,
                        fontSize,
                        expressionColor,
                        mathStyle,
                        fontWeight,
                        fontStyle,
                        textDecoration,
                      );

            return Container(
              padding: EdgeInsets.all(containerPadding),
              margin: EdgeInsets.all(containerMargin),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: containerBorderColor),
                borderRadius: BorderRadius.circular(containerBorderRadius),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: mathContent,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMathForkExpression(
    String expression,
    double fontSize,
    Color expressionColor,
    math_fork.MathStyle mathStyle,
    FontWeight fontWeight,
    FontStyle fontStyle,
    TextDecoration textDecoration,
  ) {
    try {
      // Only remove double backslashes and add spacing
      final preparedExpression = expression
          .replaceAll(r'\\', r'\')
          .replaceAll('+', ' + ')
          .replaceAll('-', ' - ')
          .replaceAll('*', ' \\cdot ')
          .replaceAll('/', ' \\div ')
          .trim();

      return math_fork.Math.tex(
        preparedExpression,
        mathStyle: mathStyle,
        textStyle: TextStyle(
          fontSize: fontSize,
          color: expressionColor,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          decoration: textDecoration,
        ),
        onErrorFallback: (e) {
          log('LaTeX Error: ${e.message}');
          // Return simplified expression on error
          return Text(expression, style: TextStyle(color: expressionColor));
        },
      );
    } catch (e) {
      log('Rendering Error: $e');
      return Text(expression, style: TextStyle(color: expressionColor));
    }
  }

  Widget _buildEasyLatexExpression(
    String expression,
    double fontSize,
    Color expressionColor,
  ) {
    return Latex(
      expression,
      fontSize: fontSize,
      color: expressionColor,
      wrapMode: LatexWrapMode.smart,
      customFont: LatexFont('Latin Modern Math', isSansSerif: true),
      backgroundColor: Colors.transparent,
    );
  }

  /// Maps CustomTextDecoration to Flutter's TextDecoration
  TextDecoration _mapCustomTextDecorationToTextDecoration(
      CustomTextDecoration customDecoration) {
    switch (customDecoration) {
      case CustomTextDecoration.none:
        return TextDecoration.none;
      case CustomTextDecoration.underline:
        return TextDecoration.underline;
      case CustomTextDecoration.overline:
        return TextDecoration.overline;
      case CustomTextDecoration.lineThrough:
        return TextDecoration.lineThrough;
      default:
        return TextDecoration.none;
    }
  }
}
