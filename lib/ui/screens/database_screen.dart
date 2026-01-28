import 'dart:io';

import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
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
              SizedBox(height: 10),
              if (Platform.isLinux)
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
                    importDatabaseDesktop();
                  },
                )
              else if (Platform.isWindows)
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
                    importDatabaseDesktop();
                  },
                )
              else if (Platform.isAndroid)
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
                    importDatabaseAndroid();
                  },
                )
              else
                ListTile(
                  leading: Icon(
                    Icons.error,
                    color: context.appColors.settingsIconsColor,
                  ),
                  title: Text(
                    'This Platform is not supported for importing database yet.',
                    style: TextStyle(
                      color: context.appColors.settingsTextColor,
                    ),
                  ),
                  onTap: () {},
                ),

              if (Platform.isLinux)
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
                    exportDatabaseDesktop();
                  },
                )
              else if (Platform.isWindows)
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
                    exportDatabaseDesktop();
                  },
                )
              else if (Platform.isAndroid)
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
                    exportDatabaseAndroid();
                  },
                )
              else
                ListTile(
                  leading: Icon(Icons.error),
                  title: Text(
                    'This Platform is not supported for exporting database yet.',
                    style: TextStyle(
                      color: context.appColors.settingsTextColor,
                    ),
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
