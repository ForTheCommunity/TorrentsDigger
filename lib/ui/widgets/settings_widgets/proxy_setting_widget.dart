import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/proxy_settings_bloc/bloc/proxy_settings_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';

class ProxySettingWidget extends StatelessWidget {
  const ProxySettingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Global key to uniquely identify the Form widget and enable validation
    final formKey = GlobalKey<FormState>();
    final TextEditingController ipController = TextEditingController();
    final TextEditingController portController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return BlocBuilder<ProxySettingsBloc, ProxySettingsState>(
      builder: (context, state) {
        if (state.proxyDetails.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.greenColor),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Proxy Protocol Selection Button.
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PopupMenuButton<String>(
                    offset: const Offset(1.0, 0.0),
                    onSelected: (protocol) {
                      context.read<ProxySettingsBloc>().add(
                        SelectProxyProtocol(selectedProxyProtocol: protocol),
                      );
                    },
                    itemBuilder: (BuildContext context) {
                      // creating a mutable copy
                      // and sorting in ascending order according to int of tuple.
                      final ascSortedProxyDetails = List<(int, String)>.from(
                        state.proxyDetails,
                      )..sort((a, b) => a.$1.compareTo(b.$1));

                      // mapping sorted list to a list of PopupMenuItem Widgets.
                      return ascSortedProxyDetails.map((proxyDetail) {
                        // final protocolId = proxyDetail.$1;
                        final protocolName = proxyDetail.$2;
                        return PopupMenuItem<String>(
                          value: protocolName,
                          child: Text(protocolName),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sourcesDropdownBackgroundColor,
                        border: Border.symmetric(
                          vertical: BorderSide(
                            width: 2,
                            color: AppColors.greenColor,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Protocol: ${state.selectedProxy ?? 'NONE'}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.pureWhite,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                if (state.selectedProxy != 'NONE') ...[
                  // IP Address Input Field
                  TextFormField(
                    controller: ipController,
                    decoration: const InputDecoration(
                      labelText: 'IP Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.computer),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an IP address';
                      }
                      //  IP validation logic here
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Port Number Input Field
                  TextFormField(
                    controller: portController,
                    decoration: const InputDecoration(
                      labelText: 'Port Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lan),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a port number';
                      }
                      //  port validation here
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Username Input Field
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Password Input Field
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 32.0),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      'Save Settings',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
