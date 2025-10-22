import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'default_trackers_event.dart';
part 'default_trackers_state.dart';
part 'default_trackers_bloc.freezed.dart';

class DefaultTrackersBloc
    extends Bloc<DefaultTrackersEvent, DefaultTrackersState> {
  DefaultTrackersBloc() : super(_Initial()) {
    on<_LoadTrackersList>(_loadTrackersList);
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
}
