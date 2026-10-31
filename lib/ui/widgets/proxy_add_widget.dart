import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/proxy_settings_bloc/proxy_settings_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';

class ProxyAddWidget extends StatefulWidget {
  final List<(int, String)> proxyDetails;
  final String? selectedProxy;

  const ProxyAddWidget({
    super.key,
    required this.proxyDetails,
    this.selectedProxy,
  });

  @override
  State<ProxyAddWidget> createState() => _ProxyAddWidgetState();
}

class _ProxyAddWidgetState extends State<ProxyAddWidget> {
  final _formKey = GlobalKey<FormState>();
  final _proxyNameController = TextEditingController();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _proxyNameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: TextStyle(
        color: context.appColors.generalTextColor,
        fontSize: 13,
      ),
      labelStyle: TextStyle(
        color: context.appColors.generalTextColor,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: context.appColors.proxyFormFieldIconColor,
        size: 20,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: context.appColors.scaffoldColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: context.appColors.textFormFieldInactiveColor,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: context.appColors.textFormFieldInactiveColor,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: context.appColors.textFormFieldActiveColor,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: context.appColors.proxyFormFieldValidationErrorMessageColor,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: context.appColors.proxyFormFieldValidationErrorMessageColor,
          width: 2.0,
        ),
      ),
      errorStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: context.appColors.proxyFormFieldValidationErrorMessageColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProtocolSelected =
        widget.selectedProxy != null &&
        widget.selectedProxy != 'NONE' &&
        widget.selectedProxy!.isNotEmpty;

    // Filter out NONE to show as selectable protocols
    final availableProtocols = List<(int, String)>.from(widget.proxyDetails)
      ..sort((a, b) => a.$1.compareTo(b.$1));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: context.appColors.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: context.appColors.textFormFieldInactiveColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.appColors.proxyDropdownBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.vpn_lock_outlined,
                        color: context.appColors.proxyIconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add Proxy Server",
                            style: TextStyle(
                              color: context.appColors.generalTextColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Route traffic through a custom proxy",
                            style: TextStyle(
                              color: context.appColors.generalTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Protocol Selector Section
                Text(
                  "Proxy Protocol",
                  style: TextStyle(
                    color: context.appColors.generalTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                // Choice Chips for protocol selection
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: availableProtocols.map((detail) {
                    final protocol = detail.$2;
                    final isSelected = widget.selectedProxy == protocol;
                    final isNone = protocol == 'NONE';

                    return ChoiceChip(
                      showCheckmark: false,
                      avatar: isSelected
                          ? Icon(
                              isNone ? Icons.block : Icons.check_circle,
                              size: 16,
                              color: context.appColors.proxyProtocolTextColor,
                            )
                          : null,
                      label: Text(
                        isNone ? 'Disabled (None)' : protocol,
                        style: TextStyle(
                          color: isSelected
                              ? context.appColors.proxyProtocolTextColor
                              : context.appColors.generalTextColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor:
                          context.appColors.proxyDropdownBackgroundColor,
                      backgroundColor: context.appColors.scaffoldColor,
                      side: BorderSide(
                        color: isSelected
                            ? context.appColors.proxyProtocolTextColor
                            : context.appColors.textFormFieldInactiveColor,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      onSelected: (selected) {
                        context.read<ProxySettingsBloc>().add(
                          SelectProxyProtocolEvent(
                            selectedProxyProtocol: selected ? protocol : 'NONE',
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                if (!hasProtocolSelected)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.appColors.scaffoldColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.appColors.textFormFieldInactiveColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: context.appColors.generalTextColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Select a protocol (e.g. HTTP or SOCKS5) above to configure proxy connection settings.",
                            style: TextStyle(
                              color: context.appColors.generalTextColor,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // Proxy Name
                  TextFormField(
                    controller: _proxyNameController,
                    decoration: _buildInputDecoration(
                      context: context,
                      labelText: 'Proxy Name',
                      hintText: 'e.g. Fast SOCKS5 US',
                      prefixIcon: Icons.label_outline,
                    ),
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: context.appColors.generalTextColor),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please provide a name for this proxy';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Host & Port Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: _ipController,
                          decoration: _buildInputDecoration(
                            context: context,
                            labelText: 'Host / IP Address',
                            hintText: '192.168.1.1 or proxy.com',
                            prefixIcon: Icons.dns_outlined,
                          ),
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                            color: context.appColors.generalTextColor,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter IP or hostname';
                            }
                            final trimmed = value.trim();
                            final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
                            final hostRegex = RegExp(
                              r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$|^localhost$',
                            );
                            if (!ipRegex.hasMatch(trimmed) &&
                                !hostRegex.hasMatch(trimmed)) {
                              return 'Invalid IP or host';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          controller: _portController,
                          decoration: _buildInputDecoration(
                            context: context,
                            labelText: 'Port',
                            hintText: '8080',
                            prefixIcon: Icons.numbers_outlined,
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: context.appColors.generalTextColor,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            final port = int.tryParse(value.trim());
                            if (port == null || port < 1 || port > 65535) {
                              return '1 - 65535';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Authentication Section Header
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 15,
                        color: context.appColors.generalTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Authentication (Optional)",
                        style: TextStyle(
                          color: context.appColors.generalTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(
                          color: context.appColors.textFormFieldInactiveColor,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: _buildInputDecoration(
                      context: context,
                      labelText: 'Username',
                      hintText: 'Leave empty if unauthenticated',
                      prefixIcon: Icons.person_outline,
                    ),
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: context.appColors.generalTextColor),
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    decoration: _buildInputDecoration(
                      context: context,
                      labelText: 'Password',
                      hintText: 'Leave empty if unauthenticated',
                      prefixIcon: Icons.key_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: context.appColors.proxyFormFieldIconColor,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    style: TextStyle(color: context.appColors.generalTextColor),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text(
                      'Save Proxy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ProxySettingsBloc>().add(
                          SaveProxyEvent(
                            proxyName: _proxyNameController.text.trim(),
                            proxyType: widget.selectedProxy ?? '',
                            proxyServerIp: _ipController.text.trim(),
                            proxyServerPort: _portController.text.trim(),
                            proxyUsername: _usernameController.text.trim(),
                            proxyPassword: _passwordController.text.trim(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      backgroundColor:
                          context.appColors.proxySaveButtonBackgroundColor,
                      foregroundColor:
                          context.appColors.proxySaveButtonTextColor,
                      side: BorderSide(
                        color: context.appColors.proxySaveButtonBorderColor,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
