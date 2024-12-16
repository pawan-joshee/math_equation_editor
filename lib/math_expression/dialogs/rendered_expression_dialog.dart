import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_math_fork/flutter_math.dart' as math_fork;

import '../../bloc/settings/settings_bloc.dart';
import '../../data/models/settings_model.dart';
import '../../widgets/custom_color_picker.dart';
import '../rendered_expression.dart';
import '../types/latex_renderer.dart';
import '../utils/custom_text_decoration.dart';

class RenderedExpressionDialog extends StatelessWidget {
  const RenderedExpressionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      insetAnimationCurve: Curves.fastLinearToSlowEaseIn,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoadSuccess) {
            final settings = state.settings;
            return Container(
              padding: const EdgeInsets.all(16.0),
              constraints: const BoxConstraints(
                maxWidth: 800,
                maxHeight: 600,
              ),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expression Preview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        mouseCursor: WidgetStateMouseCursor.clickable,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // LaTeX Renderer Selection
                  _buildDropdownButtonFormField(context, settings),
                  const SizedBox(height: 8),
                  // Updated Preview Section with label outside
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
                    child: Text(
                      'Live Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.1,
                      maxScale: 4.0,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(settings.containerPadding),
                          margin: EdgeInsets.all(settings.containerMargin),
                          height: settings.containerHeight,
                          width: settings.containerWidth,
                          decoration: BoxDecoration(
                            color: settings.backgroundColor,
                            border: Border.all(
                              color: settings.containerBorderColor,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(
                              settings.containerBorderRadius,
                            ),
                          ),
                          child: DefaultTextStyle(
                            style: TextStyle(
                              fontSize: settings.fontSize,
                              color: settings.expressionColor,
                              fontWeight: settings.fontWeight,
                              fontStyle: settings.fontStyle,
                            ),
                            child: const RenderedExpression(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Rest of the settings
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // No need for Settings info
                          // Settings sections
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSettingsSection(
                                'Text Style',
                                [
                                  _buildDropdownTile<FontWeight>(
                                    'Font Weight',
                                    settings.fontWeight,
                                    FontWeight.values,
                                    (FontWeight? value) {
                                      if (value != null) {
                                        context
                                            .read<SettingsBloc>()
                                            .add(UpdateSetting(
                                              key: 'fontWeight',
                                              value: value,
                                            ));
                                      }
                                    },
                                    'Choose the font weight',
                                  ),
                                  _buildDropdownTile<FontStyle>(
                                    'Font Style',
                                    settings.fontStyle,
                                    FontStyle.values,
                                    (FontStyle? value) {
                                      if (value != null) {
                                        context
                                            .read<SettingsBloc>()
                                            .add(UpdateSetting(
                                              key: 'fontStyle',
                                              value: value,
                                            ));
                                      }
                                    },
                                    'Choose the font style',
                                  ),
                                  _buildDropdownTile<CustomTextDecoration>(
                                    'Text Decoration',
                                    settings.textDecoration,
                                    CustomTextDecoration.values,
                                    (CustomTextDecoration? value) {
                                      if (value != null) {
                                        context
                                            .read<SettingsBloc>()
                                            .add(UpdateSetting(
                                              key: 'textDecoration',
                                              value: value,
                                            ));
                                      }
                                    },
                                    'Choose the text decoration',
                                  ),
                                  _buildSliderTile(
                                    'Font Size',
                                    settings.fontSize,
                                    10.0,
                                    200.0,
                                    (value) {
                                      context
                                          .read<SettingsBloc>()
                                          .add(UpdateSetting(
                                            key: 'fontSize',
                                            value: value,
                                          ));
                                    },
                                    'Adjust the font size for rendered text',
                                  ),
                                ],
                              ),
                              const Divider(),
                              _buildSettingsSection(
                                'Container Style',
                                [
                                  _buildSliderTile(
                                    'Padding',
                                    settings.containerPadding,
                                    0.0,
                                    50.0,
                                    (value) {
                                      context
                                          .read<SettingsBloc>()
                                          .add(UpdateSetting(
                                            key: 'containerPadding',
                                            value: value,
                                          ));
                                    },
                                    'Set the padding inside the container',
                                  ),
                                  _buildSliderTile(
                                    'Margin',
                                    settings.containerMargin,
                                    0.0,
                                    50.0,
                                    (value) {
                                      context
                                          .read<SettingsBloc>()
                                          .add(UpdateSetting(
                                            key: 'containerMargin',
                                            value: value,
                                          ));
                                    },
                                    'Set the margin around the container',
                                  ),
                                  _buildColorPickerTile(
                                    'Border Color',
                                    settings.containerBorderColor,
                                    (color) {
                                      context
                                          .read<SettingsBloc>()
                                          .add(UpdateSetting(
                                            key: 'containerBorderColor',
                                            value: color,
                                          ));
                                    },
                                    'Select the border color of the container',
                                    context,
                                  ),
                                  _buildSliderTile(
                                    'Border Radius',
                                    settings.containerBorderRadius,
                                    0.0,
                                    50.0,
                                    (value) {
                                      context
                                          .read<SettingsBloc>()
                                          .add(UpdateSetting(
                                            key: 'containerBorderRadius',
                                            value: value,
                                          ));
                                    },
                                    'Set the border radius for rounded corners',
                                  ),
                                  _buildSliderTile(
                                    'Container Height',
                                    settings.containerHeight.clamp(50.0, 500.0),
                                    50.0,
                                    500.0,
                                    (value) {
                                      context
                                          .read<SettingsBloc>()
                                          .add(UpdateSetting(
                                            key: 'containerHeight',
                                            value: value,
                                          ));
                                    },
                                    'Set the height of the container',
                                  ),
                                  _buildSliderTile(
                                    'Container Width',
                                    settings.containerWidth.clamp(50.0, 500.0),
                                    50.0,
                                    500.0,
                                    (value) {
                                      context
                                          .read<SettingsBloc>()
                                          .add(UpdateSetting(
                                            key: 'containerWidth',
                                            value: value,
                                          ));
                                    },
                                    'Set the width of the container',
                                  ),
                                ],
                              ),
                              const Divider(),
                              _buildSettingsSection(
                                'Appearance',
                                [
                                  _buildSwitchTile(
                                    'High Contrast Mode',
                                    settings.highContrastMode,
                                    (value) {
                                      context
                                          .read<SettingsBloc>()
                                          .add(UpdateSetting(
                                            key: 'highContrastMode',
                                            value: value,
                                          ));
                                    },
                                    'Enhance visibility with high contrast colors',
                                  ),
                                  _buildSwitchTile(
                                    'Custom Fonts',
                                    settings.useCustomFonts,
                                    (value) {
                                      context
                                          .read<SettingsBloc>()
                                          .add(UpdateSetting(
                                            key: 'useCustomFonts',
                                            value: value,
                                          ));
                                    },
                                    'Use custom mathematical fonts',
                                  ),
                                  if (settings.useCustomFonts)
                                    _buildDropdownTile<String>(
                                      'Math Font',
                                      settings.mathFont,
                                      [
                                        'Latin Modern Math',
                                        'STIX Two Math',
                                        'Asana Math',
                                      ],
                                      (String? value) {
                                        if (value != null) {
                                          context
                                              .read<SettingsBloc>()
                                              .add(UpdateSetting(
                                                key: 'mathFont',
                                                value: value,
                                              ));
                                        }
                                      },
                                      'Choose mathematical font family',
                                    ),
                                  const SizedBox(height: 16),
                                  _buildColorPickerTile(
                                    'Expression Color',
                                    settings.expressionColor,
                                    (color) {
                                      context
                                          .read<SettingsBloc>()
                                          .add(UpdateSetting(
                                            key: 'expressionColor',
                                            value: color,
                                          ));
                                    },
                                    'Select the color of the math expression',
                                    context,
                                  ),
                                  _buildColorPickerTile(
                                    'Background Color',
                                    settings.backgroundColor,
                                    (color) {
                                      context
                                          .read<SettingsBloc>()
                                          .add(UpdateSetting(
                                            key: 'backgroundColor',
                                            value: color,
                                          ));
                                    },
                                    'Select the background color behind the expression',
                                    context,
                                  ),
                                  _buildMathStyleTile(
                                    'Math Style',
                                    settings.mathStyle,
                                    (style) {
                                      if (style != null) {
                                        context
                                            .read<SettingsBloc>()
                                            .add(UpdateSetting(
                                              key: 'mathStyle',
                                              value: style,
                                            ));
                                      }
                                    },
                                    'Choose the math rendering style',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is SettingsLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Text('Failed to load settings.');
          }
        },
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        dense: true,
      ),
    );
  }

  Widget _buildDropdownTile<T>(
    String title,
    T value,
    List<T> items,
    ValueChanged<T?> onChanged,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: ListTile(
        title: Text(title),
        trailing: DropdownButton<T>(
          value: value,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString().split('.').last.capitalize()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        dense: true,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String tooltip, {
    bool enabled = true,
  }) {
    return Tooltip(
      message: tooltip,
      child: ListTile(
        title: Text(title),
        subtitle: Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          label: value.round().toString(),
          onChanged: enabled ? onChanged : null,
        ),
        dense: true,
      ),
    );
  }

  Widget _buildColorPickerTile(
    String title,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
    String tooltip,
    BuildContext context,
  ) {
    return Tooltip(
      message: tooltip,
      child: ListTile(
        title: Text(title),
        trailing: GestureDetector(
          onTap: () async {
            Color? pickedColor = await showDialog<Color>(
              context: context,
              builder: (context) {
                Color tempColor = currentColor;
                return AlertDialog(
                  title: Text('Select $title'),
                  content: SingleChildScrollView(
                    child: CustomColorPicker(
                      initialColor: tempColor,
                      onColorSelected: (color) {
                        tempColor = color;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: const Text('Select'),
                      onPressed: () {
                        Navigator.of(context).pop(tempColor);
                      },
                    ),
                  ],
                );
              },
            );

            if (pickedColor != null && pickedColor != currentColor) {
              onColorChanged(pickedColor);
            }
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey),
            ),
          ),
        ),
        dense: true,
      ),
    );
  }

  Widget _buildMathStyleTile(
    String title,
    math_fork.MathStyle currentStyle,
    ValueChanged<math_fork.MathStyle?> onStyleChanged,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: ListTile(
        title: Text(title),
        trailing: DropdownButton<math_fork.MathStyle>(
          value: currentStyle,
          items: math_fork.MathStyle.values.map((math_fork.MathStyle style) {
            return DropdownMenuItem<math_fork.MathStyle>(
              value: style,
              child: Text(style.toString().split('.').last.capitalize()),
            );
          }).toList(),
          onChanged: onStyleChanged,
        ),
        dense: true,
      ),
    );
  }

  Widget _buildDropdownButtonFormField(
      BuildContext context, Settings settings) {
    return DropdownButtonFormField<LatexRenderer>(
      value: settings.latexRenderer,
      decoration: const InputDecoration(
        labelText: 'LaTeX Renderer',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      onChanged: (LatexRenderer? value) {
        if (value != null) {
          context.read<SettingsBloc>().add(
                UpdateSetting(
                  key: 'latexRenderer',
                  value: value,
                ),
              );
        }
      },
      items: LatexRenderer.values.map((renderer) {
        return DropdownMenuItem(
          value: renderer,
          child: Text(
            renderer == LatexRenderer.mathFork
                ? 'Flutter Math Fork'
                : 'Easy LaTeX',
          ),
        );
      }).toList(),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
