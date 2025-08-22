import 'package:flutter/material.dart';
import 'package:torrents_digger/routes/routes_name.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RoutesName.mainUi);
                      },
                      icon: Icon(Icons.arrow_back),
                      iconSize: 30,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                SizedBox(height: 25),
                ListTile(
                  leading: const Icon(Icons.settings_ethernet),
                  title: const Text('Proxy'),
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.proxySettingUi);
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.settings_ethernet),
                //   title: const Text('Proxy'),
                //   onTap: () {},
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
