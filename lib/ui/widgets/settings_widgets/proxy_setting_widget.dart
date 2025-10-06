// This whole proxy widget is for temporary use,
// this implementation is not perfect, it is just for prototyping.
// Future<TODO> : REPLACE THIS WIDGET WITH MORE ROBUST WIDGET Implementation.

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
    final TextEditingController proxyNameController = TextEditingController();
    final TextEditingController ipController = TextEditingController();
    final TextEditingController portController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return BlocBuilder<ProxySettingsBloc, ProxySettingsState>(
      builder: (context, state) {
        if (state.proxyDetails == null || state.proxyDetails!.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.greenColor),
          );
        }

        // if proxy is not saved....
        if (state.savedProxy == null ||
            state.savedProxy!.id == 0 ||
            state.savedProxy!.id.isNaN) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Label <Todo: Imporove Later....>
                  Text(
                    "   Add Proxy :",
                    style: TextStyle(color: AppColors.greenColor, fontSize: 15),
                  ),
                  // Proxy Protocol Selection Button.
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: PopupMenuButton<String>(
                      offset: const Offset(1.0, 0.0),
                      onSelected: (protocol) {
                        context.read<ProxySettingsBloc>().add(
                          SelectProxyProtocolEvent(
                            selectedProxyProtocol: protocol,
                          ),
                        );
                      },
                      itemBuilder: (BuildContext context) {
                        // creating a mutable copy
                        // and sorting in ascending order according to int of tuple.
                        final ascSortedProxyDetails = List<(int, String)>.from(
                          state.proxyDetails!,
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
                  if (state.selectedProxy != 'NONE' &&
                      (state.selectedProxy?.isNotEmpty ?? false)) ...[
                    // Proxy Name Input Field
                    TextFormField(
                      controller: proxyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Proxy Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Set a name for proxy.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

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
                          return 'Please enter a valid IP address';
                        }
                        // Regex check for IPv4 format
                        final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
                        if (!ipRegex.hasMatch(value.trim())) {
                          return 'Enter a valid IPv4 address (e.g., 192.168.1.1)';
                        }
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
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<ProxySettingsBloc>().add(
                            SaveProxyEvent(
                              proxyName: proxyNameController.text.trim(),
                              proxyType: state.selectedProxy ?? '',
                              proxyServerIp: ipController.text.trim(),
                              proxyServerPort: portController.text.trim(),
                              proxyUsername: usernameController.text.trim(),
                              proxyPassword: passwordController.text.trim(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text(
                        'Save Proxy',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // if proxy is already saved....
        final saved = state.savedProxy!;
        final proxyId = saved.id;
        final proxyName = saved.proxyName;
        final proxyType = saved.proxyType;
        final String proxyServer = saved.proxyServerIp;
        final String proxyServerPort = saved.proxyServerPort;
        final String proxyServerUsername =
            (saved.proxyUsername?.isNotEmpty ?? false)
            ? saved.proxyUsername!
            : "Not Specified";

        final String proxyServerPassword =
            saved.proxyPassword != null && saved.proxyPassword!.isNotEmpty
            ? "*****"
            : "Not Specified";

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: AppColors.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.vpn_lock, color: AppColors.greenColor),
              title: Text(
                proxyName.toUpperCase(),
                style: TextStyle(color: AppColors.greenColor, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Type : ${proxyType.toUpperCase()}",
                    style: const TextStyle(color: AppColors.greenColor),
                  ),

                  Text(
                    "Server : $proxyServer",
                    style: const TextStyle(color: AppColors.greenColor),
                  ),

                  Text(
                    "Port : $proxyServerPort",
                    style: const TextStyle(color: AppColors.greenColor),
                  ),

                  Text(
                    "Username : $proxyServerUsername",
                    style: const TextStyle(color: AppColors.greenColor),
                  ),

                  Text(
                    "Password : $proxyServerPassword",
                    style: const TextStyle(color: AppColors.greenColor),
                  ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {
                  context.read<ProxySettingsBloc>().add(
                    DeleteProxyEvent(proxyId: proxyId),
                  );
                },
                icon: const Icon(Icons.delete, color: AppColors.brightRed),
              ),
            ),
          ),
        );
      },
    );
  }
}
