import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/blocs/customs_bloc/customs_dropdown_bloc/customs_bloc.dart';
import 'package:torrents_digger/blocs/customs_bloc/customs_torrents/customs_torrents_bloc.dart';
import 'package:torrents_digger/blocs/default_trackers_bloc/default_trackers_bloc.dart';
import 'package:torrents_digger/blocs/proxy_settings_bloc/proxy_settings_bloc.dart';
import 'package:torrents_digger/blocs/pagination_bloc/pagination_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/blocs/themes_bloc/themes_bloc.dart';
import 'package:torrents_digger/blocs/torrent_bloc/torrent_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/configs/hydration.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:torrents_digger/database/initialize.dart';
import 'package:torrents_digger/routes/routes.dart';
import 'package:torrents_digger/routes/routes_name.dart';
import 'package:torrents_digger/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  // Ensuring Flutter is Initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initializing Database
  await initializeDatabase();

  // Hydration Setup
  await hydrationSetup();

  // loading Active Default TRACKERS_STRING
  await loadTrackersString();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SourceBloc()..add(LoadSources())),
        BlocProvider(create: (_) => PaginationBloc()),
        BlocProvider(
          create: (context) =>
              TorrentBloc(paginationBloc: context.read<PaginationBloc>()),
        ),
        BlocProvider(
          create: (_) => BookmarkBloc()..add(LoadBookmarkedTorrentsEvent()),
        ),
        BlocProvider(
          create: (_) => ProxySettingsBloc()..add(LoadProxyDetailsEvent()),
        ),
        BlocProvider(
          create: (_) =>
              DefaultTrackersBloc()
                ..add(DefaultTrackersEvent.loadTrackersList()),
        ),
        BlocProvider(
          create: (_) => CustomsBloc()..add(CustomsEvent.loadCustoms()),
        ),
        BlocProvider(create: (_) => CustomsTorrentsBloc()),
        BlocProvider(
          lazy: false,
          create: (_) => ThemesBloc()..add(ThemesEvent.loadTheme()),
        ),
      ],
      child: BlocBuilder<ThemesBloc, ThemesState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey:
                scaffoldMessengerKey, // Assigning the global key
            title: "Torrents Digger",
            theme: ThemeData(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: <TargetPlatform, PageTransitionsBuilder>{
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
                },
              ),
              brightness: Brightness.dark,
              scaffoldBackgroundColor: context.appColors.scaffoldColor,
              appBarTheme: AppBarTheme(
                backgroundColor: context.appColors.appBarBackgroundColor,
                titleTextStyle: TextStyle(
                  color: context.appColors.appBarTextColor,
                  fontSize: 25,
                ),
              ),
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(
                  context.appColors.scrollbarColor,
                ),
                thickness: WidgetStateProperty.all(
                  Platform.isLinux ? 8.0 : (Platform.isAndroid ? 10.0 : 8.0),
                ),
                interactive: true,
              ),
            ),
            initialRoute: RoutesName.mainScreen,
            onGenerateRoute: Routes.generateRoute,
          );
        },
      ),
    );
  }
}
