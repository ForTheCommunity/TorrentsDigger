import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'themes_event.dart';
part 'themes_state.dart';
part 'themes_bloc.freezed.dart';

class ThemesBloc extends Bloc<ThemesEvent, ThemesState> {
  ThemesBloc() : super(_Initial()) {
    on<ThemesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
