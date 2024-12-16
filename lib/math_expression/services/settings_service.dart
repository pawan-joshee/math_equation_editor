import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart' as math_fork;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/settings_model.dart'; // Ensure this path is correct
import '../utils/custom_text_decoration.dart';

/// A service class responsible for managing application settings.
class SettingsService {
  final SharedPreferences? sharedPreferences;

  SettingsService({required this.sharedPreferences});

  /// Loads settings from SharedPreferences.
  Future<Settings> loadSettings() async {
    if (sharedPreferences != null) {
      final String? jsonString = sharedPreferences!.getString('settings');
      if (jsonString != null) {
        try {
          final Map<String, dynamic> jsonMap = json.decode(jsonString);
          return Settings.fromJson(jsonMap);
        } catch (e) {
          log('Error decoding settings JSON: $e');
          return _defaultSettings();
        }
      } else {
        return _defaultSettings();
      }
    } else {
      log('SharedPreferences is null. Returning default settings.');
      return _defaultSettings();
    }
  }

  /// Provides default settings with dynamic sizing properties initialized.
  Settings _defaultSettings() {
    return Settings(
      showPreview: true,
      autoSave: true,
      autoSaveInterval: 5,
      defaultTemplate: 'article',
      useCustomFonts: false,
      mathFont: 'Latin Modern Math',
      enableAutoComplete: true,
      enableInlineSuggestions: true,
      exportFormat: 'PNG',
      highContrastMode: false,
      keyboardShortcuts: {},
      fontSize: 40.0,
      expressionColor: Colors.black,
      backgroundColor: Colors.white,
      mathStyle: math_fork.MathStyle.display,
      // Default values for new properties
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      textDecoration: CustomTextDecoration.none,
      containerPadding: 3.0,
      containerMargin: 3.0,
      containerBorderColor: Colors.transparent,
      containerBorderRadius: 8.0,
      containerHeight: 30.0, // Increased default height for better visibility
      containerWidth: 30.0, // Increased default width for better visibility
      maxWidthFactor: 0.9,
      maxHeightFactor: 0.5, // Aligned with RenderedExpression constraints
    );
  }

  /// Saves the provided [settings] to SharedPreferences.
  Future<void> saveSettings(Settings settings) async {
    if (sharedPreferences != null) {
      try {
        final String jsonString = json.encode(settings.toJson());
        await sharedPreferences!.setString('settings', jsonString);
      } catch (e) {
        log('Error saving settings: $e');
      }
    } else {
      log('SharedPreferences is null. Cannot save settings.');
    }
  }

  /// Resets settings to their default values.
  Future<void> resetSettings() async {
    if (sharedPreferences != null) {
      await sharedPreferences!.remove('settings');
      log('Settings reset to defaults.');
    } else {
      log('SharedPreferences is null. Cannot reset settings.');
    }
  }
}
