import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/settings/settings_bloc.dart';
import '../utils/custom_text_decoration.dart'; // Corrected import

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  SettingsDialogState createState() => SettingsDialogState();
}

class SettingsDialogState extends State<SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoadSuccess) {
                final settings = state.settings;
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingsSection(
                        'Editor Settings',
                        [
                          _buildSwitchTile(
                            'Show Preview',
                            settings.showPreview,
                            (value) {
                              context.read<SettingsBloc>().add(UpdateSetting(
                                    key: 'showPreview',
                                    value: value,
                                  ));
                            },
                            'Toggle real-time preview panel',
                          ),
                          _buildSwitchTile(
                            'Auto-Complete',
                            settings.enableAutoComplete,
                            (value) {
                              context.read<SettingsBloc>().add(UpdateSetting(
                                    key: 'enableAutoComplete',
                                    value: value,
                                  ));
                            },
                            'Enable symbol and expression auto-completion',
                          ),
                          _buildSwitchTile(
                            'Inline Suggestions',
                            settings.enableInlineSuggestions,
                            (value) {
                              context.read<SettingsBloc>().add(UpdateSetting(
                                    key: 'enableInlineSuggestions',
                                    value: value,
                                  ));
                            },
                            'Show inline symbol suggestions while typing',
                          ),
                          _buildDropdownTile<CustomTextDecoration>(
                            'Text Decoration',
                            settings.textDecoration,
                            CustomTextDecoration.values,
                            (CustomTextDecoration? value) {
                              if (value != null) {
                                context.read<SettingsBloc>().add(UpdateSetting(
                                      key: 'textDecoration',
                                      value: value,
                                    ));
                              }
                            },
                            'Choose the text decoration',
                          ),
                          _buildDropdownTile<String>(
                            'Default Template',
                            settings.defaultTemplate,
                            ['article', 'book', 'report', 'letter'],
                            (String? value) {
                              if (value != null) {
                                context.read<SettingsBloc>().add(UpdateSetting(
                                      key: 'defaultTemplate',
                                      value: value,
                                    ));
                              }
                            },
                            'Choose default document template',
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildSettingsSection(
                        'Auto-Save Settings',
                        [
                          _buildSwitchTile(
                            'Enable Auto-Save',
                            settings.autoSave,
                            (value) {
                              context.read<SettingsBloc>().add(UpdateSetting(
                                    key: 'autoSave',
                                    value: value,
                                  ));
                            },
                            'Automatically save your work',
                          ),
                          _buildSliderTile(
                            'Auto-Save Interval',
                            settings.autoSaveInterval.toDouble(),
                            1,
                            30,
                            (value) {
                              context.read<SettingsBloc>().add(UpdateSetting(
                                    key: 'autoSaveInterval',
                                    value: value.round(),
                                  ));
                            },
                            'Minutes between auto-saves',
                            enabled: settings.autoSave,
                          ),
                        ],
                      ),
                    ]);
              } else if (state is SettingsLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return const Text('Failed to load settings.');
              }
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<SettingsBloc>().add(ResetSettings());
          },
          child: const Text('Reset to Defaults'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  // Helper Methods Inside the Class

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
}

/// Extension method to capitalize the first letter
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
