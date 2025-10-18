part of 'settings_bloc.dart';

@freezed
class SettingsEvents with _$SettingsEvents {
  const factory SettingsEvents.checkForUpdate() = _CheckForUpdate;
  const factory SettingsEvents.getAppCurrentVersion() = _GetAppCurrentVersion;
}
