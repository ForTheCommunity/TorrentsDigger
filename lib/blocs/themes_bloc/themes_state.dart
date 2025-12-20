part of 'themes_bloc.dart';

@freezed
class ThemesState with _$ThemesState {
  const factory ThemesState.initial() = _Initial;
  const factory ThemesState.loading() = _Loading;
  const factory ThemesState.themeState({
    required AppTheme currentAppTheme,
    required String currentAppThemeName,
    required String currentAppThemeCode,
  }) = _ThemeState;
}
