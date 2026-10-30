import 'package:torrents_digger/themes/amoled_theme.dart';
import 'package:torrents_digger/themes/app_theme.dart';
import 'package:torrents_digger/themes/dark_theme.dart';
import 'package:torrents_digger/themes/light_theme.dart';
import 'package:torrents_digger/themes/matrix_theme.dart';

export 'package:torrents_digger/themes/amoled_theme.dart';
export 'package:torrents_digger/themes/app_theme.dart';
export 'package:torrents_digger/themes/dark_theme.dart';
export 'package:torrents_digger/themes/light_theme.dart';
export 'package:torrents_digger/themes/matrix_theme.dart';

/// All available themes in Torrents Digger.
final List<AppTheme> availableThemes = [
  LightTheme(),
  DarkTheme(),
  MatrixTheme(),
  AmoledTheme(),
];

/// Returns an [AppTheme] corresponding to [themeCode].
/// Defaults to [LightTheme] if [themeCode] is unrecognized.
AppTheme getThemeByCode(String? themeCode) {
  if (themeCode == null) return LightTheme();
  return availableThemes.firstWhere(
    (theme) => theme.themeCode == themeCode,
    orElse: () => LightTheme(),
  );
}
