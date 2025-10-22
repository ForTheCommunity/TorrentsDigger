part of 'default_trackers_bloc.dart';

@freezed
class DefaultTrackersState with _$DefaultTrackersState {
  const factory DefaultTrackersState.initial() = _Initial;
  const factory DefaultTrackersState.loading() = _Loading;
  const factory DefaultTrackersState.loaded({
    required List<(BigInt, String)> trackersList,
  }) = _loaded;
  // const factory DefaultTrackersState.selectedTrackersList({
  //   required BigInt selectedTrackersList,
  // }) = _selectedTrackersList;
}
