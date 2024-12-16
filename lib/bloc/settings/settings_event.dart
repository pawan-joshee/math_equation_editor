// lib/bloc/settings/settings_event.dart

part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateSetting extends SettingsEvent {
  final String key;
  final dynamic value;

  const UpdateSetting({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

class ResetSettings extends SettingsEvent {}

class InitializeKeyboardShortcuts extends SettingsEvent {}
