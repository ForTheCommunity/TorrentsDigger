part of 'bookmark_bloc.dart';

@freezed
class BookmarkState with _$BookmarkState {
  const factory BookmarkState.initial() = _Initial;
  const factory BookmarkState.loading() = _Loading;
  const factory BookmarkState.loaded({
    // loaded torrents of a category
    required List<InternalTorrent> bookmarkedTorrents,
    // Storing Currently Viewing Category ID..
    // usefull when moving torrent from one category to another.
    @Default(0) int currentlyViewingCategoryID,
    // storing current offset
    required int currentOffset,
    // false : when fewer than limit comes back.
    required bool hasMore,
  }) = _Loaded;
  const factory BookmarkState.error({required String errorMessage}) = _Error;
}

@freezed
class BookmarkedIhState with _$BookmarkedIhState {
  const factory BookmarkedIhState.initial() = _InitialIhState;
  const factory BookmarkedIhState.loading() = _IhLoadingState;
  const factory BookmarkedIhState.loaded({
    // info hashes of torrents from all categories...
    required Set<String> infoHashes,
  }) = _IhLoadedState;
}
