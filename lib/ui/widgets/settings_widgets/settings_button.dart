import 'package:flutter/material.dart';
import 'package:torrents_digger/routes/routes_name.dart';
import '../../../configs/colors.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, RoutesName.settingsUi);
      },
      tooltip: 'Settings',
      foregroundColor: AppColors.greenColor,
      backgroundColor: AppColors.pureBlack,
      hoverColor: AppColors.pureBlack,
      child: const Icon(Icons.settings),
    );
  }
}
