// lib/widgets/saved_expressions_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/math_expression/math_expression_bloc.dart';

class SavedExpressionsDialog extends StatelessWidget {
  const SavedExpressionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Saved Expressions'),
      content: SizedBox(
        width: double.maxFinite,
        child: BlocBuilder<MathExpressionBloc, MathExpressionState>(
          builder: (context, state) {
            if (state is MathExpressionLoadSuccess) {
              final expressions = state.expressions;
              if (expressions.isEmpty) {
                return const Text('No saved expressions.');
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: expressions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(expressions[index]),
                    onTap: () {
                      // Optionally, allow users to select an expression to load
                      context
                          .read<MathExpressionBloc>()
                          .add(UpdateExpression(expressions[index]));
                      Navigator.pop(context);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        context
                            .read<MathExpressionBloc>()
                            .add(DeleteExpression(expressions[index]));
                        // Implement deletion of the expression
                        // You might need to add a DeleteExpression event in the bloc
                      },
                    ),
                  );
                },
              );
            } else {
              return const Text('Failed to load expressions.');
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
