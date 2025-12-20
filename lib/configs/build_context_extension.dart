import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/themes_bloc/themes_bloc.dart';
import 'package:torrents_digger/themes/app_theme.dart';
import 'package:torrents_digger/themes/light_theme.dart';

extension AppThemeExtension on BuildContext {
  AppTheme get appColors => watch<ThemesBloc>().state.maybeWhen(
    themeState: (appColors, _, _) => appColors,
    orElse: () => LightTheme(),
  );
}
