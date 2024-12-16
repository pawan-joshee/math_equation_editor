// lib/widgets/action_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/math_expression/math_expression_bloc.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback copyAsImage;
  final VoidCallback copyLatexToClipboard;
  final VoidCallback copyAsFormula;
  final VoidCallback exportAsImage;
  final VoidCallback exportAsSVG;
  final VoidCallback saveExpression;
  final VoidCallback showRenderedExpressionSettings;
  final bool useMobileLayout;

  const ActionButtons({
    super.key,
    required this.copyAsImage,
    required this.copyLatexToClipboard,
    required this.copyAsFormula,
    required this.exportAsImage,
    required this.showRenderedExpressionSettings,
    required this.exportAsSVG,
    required this.saveExpression,
    this.useMobileLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useMobileLayout) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildMobileButtons(),
        ),
      );
    }
    return BlocListener<MathExpressionBloc, MathExpressionState>(
      listener: (context, state) {
        if (state is MathExpressionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          ElevatedButton.icon(
            onPressed: saveExpression,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
          ElevatedButton.icon(
            onPressed: copyAsImage,
            icon: const Icon(Icons.copy),
            label: const Text('Copy Image'),
          ),
          ElevatedButton.icon(
            onPressed: copyAsFormula,
            icon: const Icon(Icons.format_shapes),
            label: const Text('Copy Formula'),
          ),
          ElevatedButton.icon(
            onPressed: exportAsImage,
            icon: const Icon(Icons.image),
            label: const Text('Export Image'),
          ),
          ElevatedButton.icon(
            onPressed: exportAsSVG,
            icon: const Icon(Icons.photo_size_select_large_rounded),
            label: const Text('Export SVG'),
          ),
          ElevatedButton.icon(
            onPressed: showRenderedExpressionSettings,
            icon: const Icon(Icons.settings_suggest_outlined),
            label: const Text('Edit Inline'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMobileButtons() {
    return [
      IconButton(
        icon: const Icon(Icons.copy),
        onPressed: copyAsImage,
        tooltip: 'Copy as Image',
      ),
      // ...add other icon buttons similarly
    ];
  }
}
