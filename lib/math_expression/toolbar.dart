// lib/widgets/toolbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/math_expression/math_expression_bloc.dart';

class Toolbar extends StatelessWidget {
  final VoidCallback showFontSizeDialog;
  final VoidCallback toggleTheme;
  final String theme; // Added theme parameter

  const Toolbar({
    super.key,
    required this.showFontSizeDialog,
    required this.toggleTheme,
    required this.theme, // Required in constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
              onPressed: () {
                context.read<MathExpressionBloc>().add(UndoExpression());
              }
              // Disable if cannot undo
              ),
          IconButton(
              icon: const Icon(Icons.redo),
              tooltip: 'Redo',
              onPressed: () {
                context.read<MathExpressionBloc>().add(RedoExpression());
              }),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: showFontSizeDialog,
            tooltip: 'Font Size',
          ),
          IconButton(
            icon: Icon(theme == 'light' ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          // Add more toolbar buttons as needed
        ],
      ),
    );
  }
}
