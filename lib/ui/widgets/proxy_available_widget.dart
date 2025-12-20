import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/proxy_settings_bloc/proxy_settings_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

class ProxyAvailableWidget extends StatelessWidget {
  final InternalProxy savedProxy;
  const ProxyAvailableWidget({super.key, required this.savedProxy});

  @override
  Widget build(BuildContext context) {
    final proxyId = savedProxy.id;
    final proxyName = savedProxy.proxyName;
    final proxyType = savedProxy.proxyType;
    final String proxyServer = savedProxy.proxyServerIp;
    final String proxyServerPort = savedProxy.proxyServerPort;
    final String proxyServerUsername =
        (savedProxy.proxyUsername?.isNotEmpty ?? false)
        ? savedProxy.proxyUsername!
        : "Not Specified";

    final String proxyServerPassword =
        savedProxy.proxyPassword != null && savedProxy.proxyPassword!.isNotEmpty
        ? "*****"
        : "Not Specified";

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: context.appColors.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading:  Icon(Icons.vpn_lock, color: context.appColors.proxyIconColor),
              title: Text(
                proxyName.toUpperCase(),
                style: TextStyle(color: context.appColors.proxyTextColor, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Type : ${proxyType.toUpperCase()}",
                    style:  TextStyle(color: context.appColors.proxyTextColor,)
                  ),
                  Text(
                    "Server : $proxyServer",
                    style:  TextStyle(color: context.appColors.proxyTextColor),
                  ),
                  Text(
                    "Port : $proxyServerPort",
                    style:  TextStyle(color: context.appColors.proxyTextColor),
                  ),
                  Text(
                    "Username : $proxyServerUsername",
                    style:  TextStyle(color: context.appColors.proxyTextColor),
                  ),
                  Text(
                    "Password : $proxyServerPassword",
                    style:  TextStyle(color: context.appColors.proxyTextColor),
                  ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {
                  context.read<ProxySettingsBloc>().add(
                    DeleteProxyEvent(proxyId: proxyId),
                  );
                },
                icon:  Icon(Icons.delete, color: context.appColors.proxyDeleteIconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
