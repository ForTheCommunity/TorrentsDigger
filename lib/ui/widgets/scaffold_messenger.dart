import 'package:flutter/material.dart';

// global key for Scaffold Messenger so that it can
// popup in any screen/widget.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void createSnackBar({required String message, required int duration}) {
  //  checks whether the ScaffoldMessenger widget
  //  has been mounted in the widget tree and is ready to be used.
  if (scaffoldMessengerKey.currentState != null) {
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
        ),
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.fixed,
        backgroundColor: Color.fromRGBO(1, 1, 1, 1),
        shape: Border.all(color: Color.fromRGBO(38, 255, 0, 1), width: 2),
      ),
    );
  }
}
