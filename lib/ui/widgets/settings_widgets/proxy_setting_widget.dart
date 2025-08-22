import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/global_key.dart';

enum ProxyProtocol { http, https, socks5 }

class ProxySettingWidget extends StatefulWidget {
  const ProxySettingWidget({super.key});

  @override
  State<ProxySettingWidget> createState() => _ProxySettingWidgetState();
}

class _ProxySettingWidgetState extends State<ProxySettingWidget> {
  // Global key to uniquely identify the Form widget and enable validation
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variable to hold the selected protocol
  ProxyProtocol _selectedProtocol = ProxyProtocol.http;

  @override
  void dispose() {
    // Dispose the controllers when the widget is removed from the tree
    _ipController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveProxySettings() {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      // If the form is valid, show a snackbar with the saved data
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'Saved: Protocol: ${_selectedProtocol.name.toUpperCase()}, '
      //       'IP: ${_ipController.text}, Port: ${_portController.text}, '
      //       'Username: ${_usernameController.text}, Password: ${_passwordController.text}',
      //     ),
      //   ),
      // );
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Underdevelopment')),
      );
      // actual save logic here,
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Protocol Selection Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: PopupMenuButton<ProxyProtocol>(
                  onSelected: (ProxyProtocol protocol) {
                    setState(() {
                      _selectedProtocol = protocol;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return ProxyProtocol.values.map((ProxyProtocol protocol) {
                      return PopupMenuItem<ProxyProtocol>(
                        value: protocol,
                        child: Text(protocol.name.toUpperCase()),
                      );
                    }).toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Protocol: ${_selectedProtocol.name.toUpperCase()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // IP Address Input Field
              TextFormField(
                controller: _ipController,
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
                controller: _portController,
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
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16.0),

              // Password Input Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32.0),

              // Save Button
              ElevatedButton(
                onPressed: _saveProxySettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
