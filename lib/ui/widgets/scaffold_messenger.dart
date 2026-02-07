import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/themes_bloc/themes_bloc.dart';
import 'package:torrents_digger/themes/light_theme.dart';

// global key for Scaffold Messenger so that it can
// popup in any screen/widget.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void createSnackBar({required String message, required int duration}) {
  //  checks whether the ScaffoldMessenger widget
  //  has been mounted in the widget tree and is ready to be used.
  if (scaffoldMessengerKey.currentState != null) {
    /// accessing the [BuildContext] of the [ScaffoldMessenger] widget
    final context = scaffoldMessengerKey.currentState!.context;

    /// accessing the [AppTheme] state from the [ThemesBloc]
    final appColors = context.read<ThemesBloc>().state.maybeWhen(
      themeState: (appColors, _, _) => appColors,
      orElse: () => LightTheme(),
    );

    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Container(
          margin: Platform.isAndroid || Platform.isIOS
              ? const EdgeInsets.only(left: 5, right: 5, bottom: 5)
              : Platform.isWindows || Platform.isLinux || Platform.isMacOS
              ? const EdgeInsets.only(left:10, right:10, bottom:10)
              : const EdgeInsets.only(left: 5, right: 5, bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: appColors.scaffoldMessengerBackgroundColor,
            border: Border.all(
              color: appColors.scaffoldMessengerBorderColor,
              width: 2,
            ),
          ),
          child: Text(
            message,
            style: TextStyle(color: appColors.scaffoldMessengerMessageColor),
          ),
        ),
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.fixed,
        backgroundColor: appColors.scaffoldMessengerBackgroundColor,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
