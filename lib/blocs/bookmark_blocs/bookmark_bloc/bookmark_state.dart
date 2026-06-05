part of 'bookmark_bloc.dart';

@freezed
class BookmarkState with _$BookmarkState {
  const factory BookmarkState.initial() = _Initial;
  const factory BookmarkState.loading() = _Loading;
  const factory BookmarkState.loaded({
    // loaded torrents of a category
    required List<InternalTorrent> bookmarkedTorrents,
    // info hashes of torrents from all categories...
    required Set<String> infoHashes,
    // Storing Currently Viewing Category ID..
    // usefull when moving torrent from one category to another.
    @Default(0) int currentlyViewingCategoryID,
  }) = _Loaded;
  const factory BookmarkState.error({required String errorMessage}) = _Error;
}
