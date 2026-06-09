part of 'bookmarks_stats_bloc.dart';

@freezed
class BookmarksStatsState with _$BookmarksStatsState {
  const factory BookmarksStatsState.initial() = _Initial;
  const factory BookmarksStatsState.loading() = _Loading;
  const factory BookmarksStatsState.loaded({
    required InternalBookmarksStats bookmarksStats,
  }) = _Loaded;
}
