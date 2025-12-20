import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/ip_info_bloc/ip_details_bloc.dart';
import 'package:torrents_digger/blocs/proxy_settings_bloc/proxy_settings_bloc.dart';
import 'package:torrents_digger/ui/widgets/ip_details_widget.dart';
import 'package:torrents_digger/ui/widgets/proxy_setting_widget.dart';

class ProxySettingScreen extends StatelessWidget {
  const ProxySettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          IpDetailsBloc()..add(const IpDetailsEvent.extractIpDetails()),
      child: BlocListener<ProxySettingsBloc, ProxySettingsState>(
        listener: (context, state) {
          // Reload IP details when proxy is saved or deleted.
          context.read<IpDetailsBloc>().add(
            const IpDetailsEvent.extractIpDetails(),
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Proxy Settings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: const SingleChildScrollView(
            child: Column(
              children: [
                ProxySettingWidget(),
                SizedBox(height: 30),
                IpDetailsWidget(),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
