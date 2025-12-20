import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/database/get_settings_kv.dart';
import 'package:torrents_digger/themes/app_theme.dart';
import 'package:torrents_digger/themes/light_theme.dart';
import 'package:torrents_digger/themes/matrix_theme.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'themes_event.dart';
part 'themes_state.dart';
part 'themes_bloc.freezed.dart';

class ThemesBloc extends Bloc<ThemesEvent, ThemesState> {
  ThemesBloc() : super(_Initial()) {
    on<_LoadTheme>(_loadColors);
    on<_ChangeTheme>(_changeTheme);
  }

  Future<void> _loadColors(_LoadTheme event, Emitter<ThemesState> emit) async {
    emit(ThemesState.loading());
    try {
      // checking saved theme in database..
      var theme = await getASettingsKv(key: "theme");

      AppTheme appTheme;

      if (theme == null) {
        // setting theme if not available in database..
        await insertOrUpdateKv(key: "theme", value: lightThemeCode);
      } else {
        // if theme is already set in database.
        switch (theme) {
          case matrixThemeCode:
            appTheme = MatrixTheme();
            break;

          case lightThemeCode:
            appTheme = LightTheme();
            break;

          default:
            appTheme = LightTheme();
            break;
        }

        emit(
          ThemesState.themeState(
            currentAppTheme: appTheme,
            currentAppThemeName: appTheme.themeName,
            currentAppThemeCode: appTheme.themeCode,
          ),
        );
      }
    } catch (e) {
      createSnackBar(message: "Error: ${e.toString}", duration: 5);
    }
  }

  void _changeTheme(_ChangeTheme event, Emitter<ThemesState> emit) async {
    emit(ThemesState.loading());
    var themeCode = event.appTheme.themeCode;

    // updating themeCode in database..
    insertOrUpdateKv(key: "theme", value: themeCode);

    AppTheme newAppTheme;

    switch (themeCode) {
      case matrixThemeCode:
        newAppTheme = MatrixTheme();
        break;
      case lightThemeCode:
        newAppTheme = LightTheme();
        break;

      default:
        newAppTheme = LightTheme();
        break;
    }
    emit(
      ThemesState.themeState(
        currentAppTheme: newAppTheme,
        currentAppThemeName: newAppTheme.themeName,
        currentAppThemeCode: newAppTheme.themeCode,
      ),
    );
  }
}
