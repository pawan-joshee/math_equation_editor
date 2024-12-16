part of 'settings_bloc.dart';

// lib/bloc/settings/settings_state.dart

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoadInProgress extends SettingsState {}

class SettingsLoadSuccess extends SettingsState {
  final Settings settings;

  const SettingsLoadSuccess(this.settings);

  @override
  List<Object> get props => [settings];
}

class SettingsLoadFailure extends SettingsState {
  final String error;

  const SettingsLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}
