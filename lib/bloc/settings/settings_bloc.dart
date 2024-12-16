import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart' as math_fork;

import '../../data/models/settings_model.dart';
import '../../math_expression/services/settings_service.dart';
import '../../math_expression/types/latex_renderer.dart';
import '../../math_expression/utils/custom_text_decoration.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService settingsService;

  SettingsBloc({required this.settingsService}) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSetting>(_onUpdateSetting);
    on<ResetSettings>(_onResetSettings);
    on<InitializeKeyboardShortcuts>(_onInitializeKeyboardShortcuts);
  }

  Future<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoadInProgress());
    try {
      final settings = await settingsService.loadSettings();
      emit(SettingsLoadSuccess(settings));
    } catch (e) {
      emit(SettingsLoadFailure(e.toString()));
    }
  }

  Future<void> _onUpdateSetting(
      UpdateSetting event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoadSuccess) {
      final currentSettings = (state as SettingsLoadSuccess).settings;

      // Create a new Settings instance with the updated value
      Settings updatedSettings = currentSettings.copyWith();

      // Update the specific setting based on the key
      switch (event.key) {
        // Existing cases...
        case 'showPreview':
          updatedSettings =
              updatedSettings.copyWith(showPreview: event.value as bool);
          break;
        case 'autoSave':
          updatedSettings =
              updatedSettings.copyWith(autoSave: event.value as bool);
          break;
        case 'autoSaveInterval':
          updatedSettings =
              updatedSettings.copyWith(autoSaveInterval: event.value as int);
          break;
        case 'defaultTemplate':
          updatedSettings =
              updatedSettings.copyWith(defaultTemplate: event.value as String);
          break;
        case 'useCustomFonts':
          updatedSettings =
              updatedSettings.copyWith(useCustomFonts: event.value as bool);
          break;
        case 'mathFont':
          updatedSettings =
              updatedSettings.copyWith(mathFont: event.value as String);
          break;
        case 'enableAutoComplete':
          updatedSettings =
              updatedSettings.copyWith(enableAutoComplete: event.value as bool);
          break;
        case 'enableInlineSuggestions':
          updatedSettings = updatedSettings.copyWith(
              enableInlineSuggestions: event.value as bool);
          break;
        case 'exportFormat':
          updatedSettings =
              updatedSettings.copyWith(exportFormat: event.value as String);
          break;
        case 'highContrastMode':
          updatedSettings =
              updatedSettings.copyWith(highContrastMode: event.value as bool);
          break;
        case 'keyboardShortcuts':
          updatedSettings = updatedSettings.copyWith(
              keyboardShortcuts:
                  Map<String, String>.from(event.value as Map<String, String>));
          break;
        case 'fontSize':
          updatedSettings =
              updatedSettings.copyWith(fontSize: event.value as double);
          break;
        case 'expressionColor':
          updatedSettings =
              updatedSettings.copyWith(expressionColor: event.value as Color);
          break;
        case 'backgroundColor':
          updatedSettings =
              updatedSettings.copyWith(backgroundColor: event.value as Color);
          break;
        case 'mathStyle':
          updatedSettings = updatedSettings.copyWith(
              mathStyle: event.value as math_fork.MathStyle);
          break;
        // New cases for TextStyle and Container styling
        case 'fontWeight':
          updatedSettings =
              updatedSettings.copyWith(fontWeight: event.value as FontWeight);
          break;
        case 'fontStyle':
          updatedSettings =
              updatedSettings.copyWith(fontStyle: event.value as FontStyle);
          break;
        case 'textDecoration':
          updatedSettings = updatedSettings.copyWith(
              textDecoration: event.value as CustomTextDecoration);
          break;
        case 'containerPadding':
          updatedSettings =
              updatedSettings.copyWith(containerPadding: event.value as double);
          break;
        case 'containerMargin':
          updatedSettings =
              updatedSettings.copyWith(containerMargin: event.value as double);
          break;
        case 'containerBorderColor':
          updatedSettings = updatedSettings.copyWith(
              containerBorderColor: event.value as Color);
          break;
        case 'containerBorderRadius':
          updatedSettings = updatedSettings.copyWith(
              containerBorderRadius: event.value as double);
          break;
        // New Cases for Container Size
        case 'containerHeight':
          updatedSettings =
              updatedSettings.copyWith(containerHeight: event.value as double);
          break;
        case 'containerWidth':
          updatedSettings =
              updatedSettings.copyWith(containerWidth: event.value as double);
          break;
        // Add new case
        case 'latexRenderer':
          updatedSettings = updatedSettings.copyWith(
              latexRenderer: event.value as LatexRenderer);
          break;
        default:
          // Handle unknown settings keys if necessary
          break;
      }

      try {
        await settingsService.saveSettings(updatedSettings);
        emit(SettingsLoadSuccess(updatedSettings));
      } catch (e) {
        emit(SettingsLoadFailure(e.toString()));
      }
    }
  }

  Future<void> _onResetSettings(
      ResetSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoadInProgress());
    try {
      await settingsService.resetSettings();
      final settings = await settingsService.loadSettings();
      emit(SettingsLoadSuccess(settings));
    } catch (e) {
      emit(SettingsLoadFailure(e.toString()));
    }
  }

  Future<void> _onInitializeKeyboardShortcuts(
      InitializeKeyboardShortcuts event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoadSuccess) {
      final currentSettings = (state as SettingsLoadSuccess).settings;
      if (currentSettings.keyboardShortcuts.isEmpty) {
        // Define default shortcuts
        Map<String, String> defaultShortcuts = {
          'Undo': 'Ctrl + Z',
          'Redo': 'Ctrl + Y',
          'Save': 'Ctrl + S',
          'Clear': 'Ctrl + C',
          // Add more default shortcuts as needed
        };

        // Update settings with default shortcuts
        Settings updatedSettings = currentSettings.copyWith(
          keyboardShortcuts: defaultShortcuts,
        );

        try {
          await settingsService.saveSettings(updatedSettings);
          emit(SettingsLoadSuccess(updatedSettings));
        } catch (e) {
          emit(SettingsLoadFailure(e.toString()));
        }
      }
    }
  }
}
