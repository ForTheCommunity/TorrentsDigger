import 'package:flutter/material.dart';
import 'package:torrents_digger/ui/widgets/settings_widgets/proxy_setting_widget.dart';

class ProxySettingScreen extends StatelessWidget {
  const ProxySettingScreen({super.key});

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
      body: Column(children: [ProxySettingWidget()]),
    );
  }
}
