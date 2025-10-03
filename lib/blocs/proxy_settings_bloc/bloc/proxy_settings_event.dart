part of 'proxy_settings_bloc.dart';

@immutable
sealed class ProxySettingsEvents {}

class LoadProxyDetails extends ProxySettingsEvents {}

class SelectProxyProtocol extends ProxySettingsEvents {
  final String selectedProxyProtocol;
  SelectProxyProtocol({required this.selectedProxyProtocol});
}
