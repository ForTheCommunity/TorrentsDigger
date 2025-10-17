part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = _Initial;
  const factory SettingsState.updateChecking() = _UpdateChecking;
  const factory SettingsState.updateAvailable() = _UpdateAvailable;
  const factory SettingsState.latestVersion() = _LatestVersion;
  const factory SettingsState.error(String message) = _Error;
}
