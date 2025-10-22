part of 'default_trackers_bloc.dart';

@freezed
class DefaultTrackersEvent with _$DefaultTrackersEvent {
  const factory DefaultTrackersEvent.started() = _Started;
  const factory DefaultTrackersEvent.loadTrackersList() = _LoadTrackersList;
  const factory DefaultTrackersEvent.setTrackersList({
    required BigInt selectedTrackerId,
  }) = _SetTrackersList;
}
