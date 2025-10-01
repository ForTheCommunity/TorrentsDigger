import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/routes/routes_name.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                    iconSize: 30,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: AppColors.greenColor,
                      letterSpacing: 2,
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
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
              ListTile(
                leading: const Icon(Icons.import_export),
                title: const Text('Database'),
                onTap: () {
                  Navigator.pushNamed(context, RoutesName.databaseScreen);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
