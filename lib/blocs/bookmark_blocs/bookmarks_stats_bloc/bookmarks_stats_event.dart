part of 'bookmarks_stats_bloc.dart';

@freezed
class BookmarksStatsEvent with _$BookmarksStatsEvent {
  const factory BookmarksStatsEvent.started() = _Started;
  const factory BookmarksStatsEvent.load() = _Load;
}
