import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/proxy_settings_bloc/proxy_settings_bloc.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/proxy_available_widget.dart';
import 'package:torrents_digger/ui/widgets/proxy_add_widget.dart';

class ProxySettingWidget extends StatelessWidget {
  const ProxySettingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProxySettingsBloc, ProxySettingsState>(
      builder: (context, state) {
        if (state.proxyDetails == null || state.proxyDetails!.isEmpty) {
          return const Center(child: CircularProgressBarWidget());
        }

        // if proxy is not saved....
        if (state.savedProxy == null ||
            state.savedProxy!.id == 0 ||
            state.savedProxy!.id.isNaN) {
          return ProxyAddWidget(
            proxyDetails: state.proxyDetails!,
            selectedProxy: state.selectedProxy,
          );
        }
        // if proxy is already saved....
        final savedProxy = state.savedProxy!;
        return ProxyAvailableWidget(savedProxy: savedProxy);
      },
    );
  }
}
