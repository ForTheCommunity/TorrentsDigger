import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/proxy_settings_bloc/proxy_settings_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';

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
              style: TextStyle(
                color: context.appColors.generalTextColor,
                fontSize: 15,
              ),
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
                    color: context.appColors.proxyDropdownBackgroundColor,
                    border: Border.symmetric(
                      vertical: BorderSide(
                        width: 2,
                        color: context.appColors.generalTextColor,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Protocol: ${selectedProxy ?? 'NONE'}',
                        style: TextStyle(
                          color: context.appColors.proxyProtocolTextColor,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: context
                            .appColors
                            .proxyProtocolArrowDropdownIconColor,
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
                decoration: InputDecoration(
                  labelText: 'Proxy Name',
                  labelStyle: TextStyle(
                    color: context.appColors.generalTextColor,
                  ),
                  prefixIcon: Icon(
                    Icons.note,
                    color: context.appColors.proxyFormFieldIconColor,
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.appColors.textFormFieldInactiveColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.appColors.textFormFieldActiveColor,
                      width: 2.0,
                    ),
                  ),
                  errorStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context
                        .appColors
                        .proxyFormFieldValidationErrorMessageColor,
                  ),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Set a name for proxy.';
                  }
                  return null;
                },
                style: TextStyle(color: context.appColors.generalTextColor),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: ipController,
                decoration: InputDecoration(
                  labelText: 'IP Address',
                  labelStyle: TextStyle(
                    color: context.appColors.generalTextColor,
                  ),
                  prefixIcon: Icon(
                    Icons.computer,
                    color: context.appColors.proxyFormFieldIconColor,
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.appColors.textFormFieldInactiveColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.appColors.textFormFieldActiveColor,
                      width: 2.0,
                    ),
                  ),
                  errorStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context
                        .appColors
                        .proxyFormFieldValidationErrorMessageColor,
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

                style: TextStyle(color: context.appColors.generalTextColor),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: portController,
                decoration: InputDecoration(
                  labelText: 'Port Number',
                  labelStyle: TextStyle(
                    color: context.appColors.generalTextColor,
                  ),
                  prefixIcon: Icon(
                    Icons.lan,
                    color: context.appColors.proxyFormFieldIconColor,
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.appColors.textFormFieldInactiveColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.appColors.textFormFieldActiveColor,
                      width: 2.0,
                    ),
                  ),
                  errorStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context
                        .appColors
                        .proxyFormFieldValidationErrorMessageColor,
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: context.appColors.generalTextColor),
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
                decoration: InputDecoration(
                  labelText: 'Username (Optional)',
                  labelStyle: TextStyle(
                    color: context.appColors.generalTextColor,
                  ),
                  prefixIcon: Icon(
                    Icons.person,
                    color: context.appColors.proxyFormFieldIconColor,
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.appColors.textFormFieldInactiveColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.appColors.textFormFieldActiveColor,
                      width: 2.0,
                    ),
                  ),
                  errorStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context
                        .appColors
                        .proxyFormFieldValidationErrorMessageColor,
                  ),
                ),
                style: TextStyle(color: context.appColors.generalTextColor),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password (Optional)',
                  labelStyle: TextStyle(
                    color: context.appColors.generalTextColor,
                  ),
                  prefixIcon: Icon(
                    Icons.key,
                    color: context.appColors.proxyFormFieldIconColor,
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.appColors.textFormFieldInactiveColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: context.appColors.textFormFieldActiveColor,
                      width: 2.0,
                    ),
                  ),
                  errorStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context
                        .appColors
                        .proxyFormFieldValidationErrorMessageColor,
                  ),
                ),
                obscureText: true,
                style: TextStyle(color: context.appColors.generalTextColor),
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
                  backgroundColor:
                      context.appColors.proxySaveButtonBackgroundColor,
                  side: BorderSide(
                    color: context.appColors.proxySaveButtonBorderColor,
                    width: 2.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'Save Proxy',
                  style: TextStyle(
                    color: context.appColors.proxySaveButtonTextColor,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
