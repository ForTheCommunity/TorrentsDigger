import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/routes/routes_name.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, RoutesName.settingsScreen);
      },
      tooltip: 'Settings',
      foregroundColor:
          context.appColors.settingsFloatingActionButtonForegroundColor,
      backgroundColor:
          context.appColors.settingsFloatingActionButtonBackgroundColor,
      hoverColor:
          context.appColors.settingsFloatingActionButtonHoverBackgroundColor,
      child: const Icon(Icons.settings),
    );
  }
}
