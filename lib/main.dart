import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/configs/global_key.dart';
import 'package:torrents_digger/routes/routes.dart';
import 'package:torrents_digger/routes/routes_name.dart';
// import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey, // Assigning the global key
      title: "Torrents Digger",
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.pureBlack,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.pureBlack,
          titleTextStyle: TextStyle(
            color: AppColors.greenColor,
            fontSize: 25,
            letterSpacing: 5,
          ),
        ),
      ),
      initialRoute: RoutesName.oxidaUi,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
