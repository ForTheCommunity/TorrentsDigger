part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = _Initial;
  // states for check for update...
  const factory SettingsState.updateChecking() = _UpdateChecking;
  const factory SettingsState.updateAvailable() = _UpdateAvailable;
  const factory SettingsState.latestVersion() = _LatestVersion;
  const factory SettingsState.checkAppUpdateError(String message) =
      _CheckAppUpdateError;
  // states for about
  const factory SettingsState.loadingCurrentVersion() = _LoadingCurrentVersion;
  const factory SettingsState.loadedCurrentVersion(String currentVersion) =
      _LoadedCurrentVersion;
  const factory SettingsState.loadCurrentVersionError(String errorMessage) =
      _LoadCurrentVersionError;
}
