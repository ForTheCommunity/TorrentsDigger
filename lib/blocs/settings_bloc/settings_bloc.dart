import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/app.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'settings_bloc.freezed.dart';

class SettingsBloc extends Bloc<SettingsEvents, SettingsState> {
  SettingsBloc() : super(_Initial()) {
    on<SettingsEvents>((event, emit) async {
      await event.map(
        checkForUpdate: (e) async => await _checkAppUpdate(e, emit),
      );
    });
  }
}

Future<void> _checkAppUpdate(
  _CheckForUpdate event,
  Emitter<SettingsState> emit,
) async {
  emit(SettingsState.updateChecking());
  try {
    final returnedValue = await checkNewUpdate();

    if (returnedValue == 0) {
      emit(const SettingsState.updateAvailable());
    }
    if (returnedValue == 1) {
      emit(const SettingsState.latestVersion());
    }
  } catch (e) {
    emit(SettingsState.error(e.toString()));
  }
}
