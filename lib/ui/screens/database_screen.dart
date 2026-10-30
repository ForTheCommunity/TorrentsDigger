import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/database/import_export.dart';

class DatabaseScreen extends StatelessWidget {
  const DatabaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              ListTile(
                leading: Icon(
                  Icons.keyboard_double_arrow_down,
                  color: context.appColors.settingsIconsColor,
                ),
                title: Text(
                  'Import Database',
                  style: TextStyle(
                    color: context.appColors.settingsTextColor,
                  ),
                ),
                onTap: () {
                  importDatabase();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.keyboard_double_arrow_up,
                  color: context.appColors.settingsIconsColor,
                ),
                title: Text(
                  'Export Database',
                  style: TextStyle(
                    color: context.appColors.settingsTextColor,
                  ),
                ),
                onTap: () {
                  exportDatabase();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
