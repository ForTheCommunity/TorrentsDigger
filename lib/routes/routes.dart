import 'package:flutter/material.dart';
import '../ui/main_ui.dart';
import 'routes_name.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case RoutesName.splashScreen:
      //   return MaterialPageRoute(builder: (context) => SplashScreen());
      case RoutesName.oxidaUi:
        return MaterialPageRoute(builder: (context) => MainUi());

      default:
        return MaterialPageRoute(
          builder: (context) {
            return const Scaffold(
              body: Center(child: Text("No Route Found..")),
            );
          },
        );
    }
  }
}
