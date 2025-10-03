part of 'proxy_settings_bloc.dart';

class ProxySettingsState {
  final List<(int, String)> proxyDetails;
  final String? selectedProxy;

  const ProxySettingsState({required this.proxyDetails, this.selectedProxy});

  ProxySettingsState copyWith({
    List<(int, String)>? proxyDetails,
    String? selectedProxy,
  }) {
    return ProxySettingsState(
      proxyDetails: proxyDetails ?? this.proxyDetails,
      selectedProxy: selectedProxy ?? this.selectedProxy,
    );
  }
}
