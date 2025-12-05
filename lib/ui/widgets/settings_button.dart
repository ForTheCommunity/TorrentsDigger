import 'package:flutter/material.dart';
import 'package:torrents_digger/routes/routes_name.dart';
import '../../configs/colors.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, RoutesName.settingsScreen);
      },
      tooltip: 'Settings',
      foregroundColor: AppColors.settingsFloatingActionButtonForegroundColor,
      backgroundColor: AppColors.settingsFloatingActionButtonBackgroundColor,
      hoverColor: AppColors.settingsFloatingActionButtonHoverBackgroundColor,
      child: const Icon(Icons.settings),
    );
  }
}
