import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/database/bookmarks.dart';
import 'package:torrents_digger/src/rust/api/database/bookmark.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'bookmark_event.dart';
part 'bookmark_state.dart';
part 'bookmark_bloc.freezed.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  int currentCategoryId = 0;
  static const int _defaultLimit = 10;

  BookmarkBloc() : super(_Initial()) {
    on<_LoadBookmarks>(_loadBookmarks);
    on<_Bookmark>(_bookmark);
    on<_RemoveBookmark>(_removeBookmark);
    on<_UpdateBookmark>(_updateBookmark);
    on<_LoadMoreBookmarks>(_loadMoreBookmarks);
  }

  Future<void> _loadBookmarks(
    _LoadBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      currentCategoryId = event.categoryID;

      emit(BookmarkState.loading());
      List<InternalTorrent> torrents = await getBookmarks(
        categoryId: event.categoryID,
        limit: _defaultLimit,
        offset: 0,
      );
      final Set<String> allInfoHashes = await getAllInfoHashes();
      emit(
        BookmarkState.loaded(
          bookmarkedTorrents: torrents,
          infoHashes: allInfoHashes,
          currentOffset: torrents.length,
          hasMore: torrents.length == _defaultLimit,
        ),
      );
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
      emit(BookmarkState.error(errorMessage: e.toString()));
    }
  }

  Future<void> _bookmark(_Bookmark event, Emitter<BookmarkState> emit) async {
    try {
      await torrentBookmark(event.torrent, event.categoryID);
      // Reloading bookmarks to reflect the change
      add(BookmarkEvent.loadBookmarks(categoryID: 0));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
    }
  }

  Future<void> _removeBookmark(
    _RemoveBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      await removeABookmark(event.infoHash);
      // Reloading bookmarks to reflect the change
      add(BookmarkEvent.loadBookmarks(categoryID: 0));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
    }
  }

  Future<void> _updateBookmark(
    _UpdateBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      await changeBookmarkCategory(
        infoHash: event.infoHash,
        categoryId: event.categoryId,
      );
      // Reloading bookmarks to reflect the change
      add(
        BookmarkEvent.loadBookmarks(
          categoryID: event.currenltyViewingCategoryID,
        ),
      );
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
    }
  }

  Future<void> _loadMoreBookmarks(
    _LoadMoreBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    final currentState = state;
    if (currentState is! _Loaded || !currentState.hasMore) return;

    try {
      final newTorrents = await getBookmarks(
        categoryId: currentCategoryId,
        limit: _defaultLimit,
        offset: currentState.currentOffset,
      );
      final allInfoHashes = await getAllInfoHashes();

      emit(
        BookmarkState.loaded(
          bookmarkedTorrents: [
            ...currentState.bookmarkedTorrents,
            ...newTorrents,
          ],
          infoHashes: allInfoHashes,
          currentOffset: currentState.currentOffset + newTorrents.length,
          hasMore: newTorrents.length == _defaultLimit,
        ),
      );
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }
}
