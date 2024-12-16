import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';

class MathFieldWidget extends StatelessWidget {
  final MathFieldEditingController controller;
  final VoidCallback onClear;

  const MathFieldWidget({
    super.key,
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        final symbol = details.data;
        controller.addLeaf(symbol);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                constraints: const BoxConstraints(
                  minHeight: 80,
                  maxHeight: 200,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: MathField(
                    controller: controller,
                    variables: const [
                      'x',
                      'y',
                      'z',
                      'r',
                      r'\theta',
                      r'\alpha',
                      'a',
                      'b',
                      'c',
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
