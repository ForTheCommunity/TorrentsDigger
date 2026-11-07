import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/database/get_settings_kv.dart';
import 'package:torrents_digger/themes/themes.dart';
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
    // If a theme is already loaded, avoid emitting loading and re-querying DB,
    // which causes full MaterialApp rebuilds and route transition jank.
    if (state is _ThemeState) {
      return;
    }

    emit(const ThemesState.loading());
    try {
      // checking saved theme in database..
      var theme = await getASettingsKv(key: "theme");

      if (theme == null || theme == "light") {
        // setting theme if not available in database or if previous was light..
        await insertOrUpdateKv(key: "theme", value: darkThemeCode);
        theme = darkThemeCode;
      }

      final AppTheme appTheme = getThemeByCode(theme);

      emit(
        ThemesState.themeState(
          currentAppTheme: appTheme,
          currentAppThemeName: appTheme.themeName,
          currentAppThemeCode: appTheme.themeCode,
        ),
      );
    } catch (e) {
      createSnackBar(message: "Error: ${e.toString()}", duration: 5);
    }
  }

  Future<void> _changeTheme(
    _ChangeTheme event,
    Emitter<ThemesState> emit,
  ) async {
    final AppTheme newAppTheme = event.appTheme;

    // Apply the selected theme immediately with zero flicker or spinner
    emit(
      ThemesState.themeState(
        currentAppTheme: newAppTheme,
        currentAppThemeName: newAppTheme.themeName,
        currentAppThemeCode: newAppTheme.themeCode,
      ),
    );

    try {
      // updating themeCode in database asynchronously
      await insertOrUpdateKv(key: "theme", value: newAppTheme.themeCode);
    } catch (e) {
      createSnackBar(
        message: "Error saving theme: ${e.toString()}",
        duration: 3,
      );
    }
  }
}
