import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/proxy_settings_bloc/proxy_settings_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';

class ProxyAddWidget extends StatelessWidget {
  final List<(int, String)> proxyDetails;
  final String? selectedProxy;
  const ProxyAddWidget({
    super.key,
    required this.proxyDetails,
    this.selectedProxy,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    TextEditingController proxyNameController = TextEditingController();
    TextEditingController ipController = TextEditingController();
    TextEditingController portController = TextEditingController();
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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
                    SelectProxyProtocolEvent(selectedProxyProtocol: protocol),
                  );
                },
                itemBuilder: (BuildContext context) {
                  final ascSortedProxyDetails = List<(int, String)>.from(
                    proxyDetails,
                  )..sort((a, b) => a.$1.compareTo(b.$1));
                  return ascSortedProxyDetails.map((proxyDetail) {
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
                        'Protocol: ${selectedProxy ?? 'NONE'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.pureWhite,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            if (selectedProxy != 'NONE' &&
                (selectedProxy?.isNotEmpty ?? false)) ...[
              TextFormField(
                controller: proxyNameController,
                decoration: const InputDecoration(
                  labelText: 'Proxy Name',
                  labelStyle: TextStyle(color: AppColors.greenColor),
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textFormFieldInactiveColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textFormFieldActiveColor,
                      width: 2.0,
                    ),
                  ),
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
              TextFormField(
                controller: ipController,
                decoration: const InputDecoration(
                  labelText: 'IP Address',
                  labelStyle: TextStyle(color: AppColors.greenColor),
                  prefixIcon: Icon(Icons.computer),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textFormFieldInactiveColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textFormFieldActiveColor,
                      width: 2.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid IP address';
                  }
                  final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
                  if (!ipRegex.hasMatch(value.trim())) {
                    return 'Enter a valid IPv4 address (e.g., 192.168.1.1)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: portController,
                decoration: const InputDecoration(
                  labelText: 'Port Number',
                  labelStyle: TextStyle(color: AppColors.greenColor),
                  prefixIcon: Icon(Icons.lan),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textFormFieldInactiveColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textFormFieldActiveColor,
                      width: 2.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a port number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (Optional)',
                  labelStyle: TextStyle(color: AppColors.greenColor),
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textFormFieldInactiveColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textFormFieldActiveColor,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (Optional)',
                  labelStyle: TextStyle(color: AppColors.greenColor),
                  prefixIcon: Icon(Icons.key),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textFormFieldInactiveColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.textFormFieldActiveColor,
                      width: 2.0,
                    ),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.read<ProxySettingsBloc>().add(
                      SaveProxyEvent(
                        proxyName: proxyNameController.text.trim(),
                        proxyType: selectedProxy ?? '',
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
                  style: TextStyle(color: AppColors.greenColor, fontSize: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
