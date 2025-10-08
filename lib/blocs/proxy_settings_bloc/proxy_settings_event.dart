part of 'proxy_settings_bloc.dart';

@immutable
sealed class ProxySettingsEvents {}

class LoadProxyDetailsEvent extends ProxySettingsEvents {}

class SelectProxyProtocolEvent extends ProxySettingsEvents {
  final String selectedProxyProtocol;
  SelectProxyProtocolEvent({required this.selectedProxyProtocol});
}

class SaveProxyEvent extends ProxySettingsEvents {
  final String proxyName;
  final String proxyType;
  final String proxyServerIp;
  final String proxyServerPort;
  final String? proxyUsername;
  final String? proxyPassword;
  SaveProxyEvent({
    required this.proxyName,
    required this.proxyType,
    required this.proxyServerIp,
    required this.proxyServerPort,
    required this.proxyUsername,
    required this.proxyPassword,
  });
}

class DeleteProxyEvent extends ProxySettingsEvents {
  final int proxyId;
  DeleteProxyEvent({required this.proxyId});
}
