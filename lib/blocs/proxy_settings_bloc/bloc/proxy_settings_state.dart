part of 'proxy_settings_bloc.dart';

@immutable
sealed class ProxyState {}

class ProxySettingsState extends ProxyState {
  final List<(int, String)> proxyDetails;
  final String? selectedProxy;
  final (int, String, String)? savedProxy;

  ProxySettingsState({
    required this.proxyDetails,
    this.selectedProxy,
    this.savedProxy,
  });

  ProxySettingsState copyWith({
    List<(int, String)>? proxyDetails,
    String? selectedProxy,
    (int, String, String)? savedProxy,
  }) {
    return ProxySettingsState(
      proxyDetails: proxyDetails ?? this.proxyDetails,
      selectedProxy: selectedProxy ?? this.selectedProxy,
      savedProxy: savedProxy ?? this.savedProxy,
    );
  }
}
