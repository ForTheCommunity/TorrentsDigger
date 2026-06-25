part of 'bookmark_bloc.dart';

@freezed
class BookmarkEvent with _$BookmarkEvent {
  const factory BookmarkEvent.started() = _Started;
  const factory BookmarkEvent.loadBookmarks({
    required int categoryID,
    @Default(10) int limit,
    @Default(0)  int offset,
  }) = _LoadBookmarks;
  const factory BookmarkEvent.bookmark({
    required InternalTorrent torrent,
    required int categoryID,
  }) = _Bookmark;
  const factory BookmarkEvent.removeBookmark({required String infoHash}) =
      _RemoveBookmark;
  const factory BookmarkEvent.updateBookmark({
    required String infoHash,
    required int categoryId,
    required int currenltyViewingCategoryID,
  }) = _UpdateBookmark;
  const factory BookmarkEvent.loadMoreBookmarks() = _LoadMoreBookmarks;
}
