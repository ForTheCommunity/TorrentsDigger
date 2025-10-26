import 'package:flutter/material.dart';
import 'package:torrents_digger/ui/screens/bookmarks_screen.dart';
import 'package:torrents_digger/ui/screens/customs_screen.dart';
import 'package:torrents_digger/ui/screens/database_screen.dart';
import 'package:torrents_digger/ui/screens/default_trackers_screen.dart';
import 'package:torrents_digger/ui/screens/proxy_setting_screen.dart';
import 'package:torrents_digger/ui/screens/settings_screen.dart';
import '../ui/screens/main_screen.dart';
import 'routes_name.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.mainScreen:
        return MaterialPageRoute(builder: (context) => const MainScreen());

      case RoutesName.settingsScreen:
        return MaterialPageRoute(builder: (context) => const SettingsScreen());

      case RoutesName.proxySettingScreen:
        return MaterialPageRoute(
          builder: (context) => const ProxySettingScreen(),
        );

      case RoutesName.bookmarksScreen:
        return MaterialPageRoute(builder: (context) => const BookmarksScreen());

      case RoutesName.databaseScreen:
        return MaterialPageRoute(builder: (context) => const DatabaseScreen());

      case RoutesName.defaultTrackersScreen:
        return MaterialPageRoute(
          builder: (context) => const DefaultTrackersScreen(),
        );

      case RoutesName.customsScreen:
        return MaterialPageRoute(builder: (context) => const CustomsScreen());

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
