import 'package:flutter/material.dart';
import 'package:torrents_digger/ui/widgets/settings_widgets/proxy_setting_widget.dart';
import 'package:torrents_digger/ui/widgets/settings_widgets/settings_widget.dart';
import '../ui/main_ui.dart';
import 'routes_name.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.mainUi:
        return MaterialPageRoute(builder: (context) => const MainUi());
      case RoutesName.settingsUi:
        return MaterialPageRoute(builder: (context) => const SettingsWidget());
      case RoutesName.proxySettingUi:
        return MaterialPageRoute(
          builder: (context) => const ProxySettingWidget(),
        );
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
