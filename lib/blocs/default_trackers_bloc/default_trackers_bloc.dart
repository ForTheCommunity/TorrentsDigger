import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/database/get_settings_kv.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'default_trackers_event.dart';
part 'default_trackers_state.dart';
part 'default_trackers_bloc.freezed.dart';

class DefaultTrackersBloc
    extends Bloc<DefaultTrackersEvent, DefaultTrackersState> {
  DefaultTrackersBloc() : super(_Initial()) {
    on<_LoadTrackersList>(_loadTrackersList);
    on<_SetTrackersList>(_setTrackersList);
  }

  Future<void> _loadTrackersList(
    _LoadTrackersList event,
    Emitter<DefaultTrackersState> emit,
  ) async {
    emit(const DefaultTrackersState.loading());
    try {
      final trackersList = await getAllDefaultTrackersList();
      emit(DefaultTrackersState.loaded(trackersList: trackersList));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
    }
  }

  Future<void> _setTrackersList(
    _SetTrackersList event,
    Emitter<DefaultTrackersState> emit,
  ) async {
    try {
      var selectedTrackersListIndex = event.selectedTrackerId.toInt();
      await setDefaultTrackersList(index: selectedTrackersListIndex);
      createSnackBar(message: "Updated Trackers List.", duration: 1);
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
    }
  }
}
