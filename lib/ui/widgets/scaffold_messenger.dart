import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';

// global key for Scaffold Messenger so that it can
// popup in any screen/widget.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void createSnackBar(String message) {
  //  checks whether the ScaffoldMessenger widget
  //  has been mounted in the widget tree and is ready to be used.
  if (scaffoldMessengerKey.currentState != null) {
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: AppColors.pureWhite)),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.fixed,
        backgroundColor: AppColors.categoriesDropdownOpenedBackgroundColor,
        shape: Border.all(color: AppColors.greenColor, width: 2),
      ),
    );
  }
}
