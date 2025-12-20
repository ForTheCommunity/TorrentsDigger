part of 'themes_bloc.dart';

@freezed
class ThemesEvent with _$ThemesEvent {
  const factory ThemesEvent.loadTheme() = _LoadTheme;
  const factory ThemesEvent.changeTheme({required AppTheme appTheme}) =
      _ChangeTheme;
}
