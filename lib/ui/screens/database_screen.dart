import 'dart:io';

import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/database/import_export_database.dart';

class DatabaseScreen extends StatelessWidget {
  const DatabaseScreen({super.key});

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
                    'Database',
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
              if (Platform.isLinux)
                ListTile(
                  leading: const Icon(Icons.keyboard_double_arrow_down),
                  title: const Text('Import Database'),
                  onTap: () {
                    importDatabaseLinux();
                  },
                )
              else if (Platform.isAndroid)
                ListTile(
                  leading: const Icon(Icons.keyboard_double_arrow_down),
                  title: const Text('Import Database'),
                  onTap: () {
                    import_database_android();
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.error),
                  title: const Text(
                    'This Platform is not supported for importing database yet.',
                  ),
                  onTap: () {},
                ),

              if (Platform.isLinux)
                ListTile(
                  leading: const Icon(Icons.keyboard_double_arrow_up),
                  title: const Text('Export Database'),
                  onTap: () {
                    exportDatabaseLinux();
                  },
                )
              else if (Platform.isAndroid)
                ListTile(
                  leading: const Icon(Icons.keyboard_double_arrow_up),
                  title: const Text('Export Database'),
                  onTap: () {
                    exportDatabaseAndroid();
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.error),
                  title: const Text(
                    'This Platform is not supported for exporting database yet.',
                  ),
                  onTap: () {},
                ),
            ],
          ),
        ],
      ),
    );
  }
}
