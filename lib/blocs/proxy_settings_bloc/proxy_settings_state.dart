part of 'proxy_settings_bloc.dart';

@freezed
abstract class ProxySettingsState with _$ProxySettingsState {
  const factory ProxySettingsState({
    required List<(int, String)>? proxyDetails,
    String? selectedProxy,
    InternalProxy? savedProxy,
  }) = _ProxySettingsState;
}
