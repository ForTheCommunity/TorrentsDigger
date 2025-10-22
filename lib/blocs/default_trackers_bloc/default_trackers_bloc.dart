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
      // loading trackers lists
      final trackersList = await getAllDefaultTrackersList();
      // loading activated trackers list.
      final String activatedDefaultTrackersListIndex =
          await getActiveDefaultTrackersList();
      final BigInt index = BigInt.parse(activatedDefaultTrackersListIndex);
      // updating states
      emit(
        DefaultTrackersState.loaded(
          trackersList: trackersList,
          activatedTrackersList: index,
        ),
      );
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
    }
  }

  Future<void> _setTrackersList(
    _SetTrackersList event,
    Emitter<DefaultTrackersState> emit,
  ) async {
    try {
      var selectedTrackersListIndex = event.selectedTrackerId;
      // saving to database
      await setDefaultTrackersList(index: selectedTrackersListIndex.toInt());
      // updating state

      // getting current state to retrieve existing tracker list
      if (state is _loaded) {
        var currentState = state as _loaded;
        emit(
          DefaultTrackersState.loaded(
            trackersList: currentState.trackersList,
            activatedTrackersList: selectedTrackersListIndex,
          ),
        );
      } else {
        createSnackBar(
          message: "STATE ERROR : Unable to get current state..",
          duration: 5,
        );
      }

      createSnackBar(message: "Updated Trackers List.", duration: 1);
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
    }
  }
}
