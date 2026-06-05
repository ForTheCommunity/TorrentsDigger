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

  BookmarkBloc() : super(_Initial()) {
    on<_LoadBookmarks>(_loadBookmarks);
    on<_Bookmark>(_bookmark);
    on<_RemoveBookmark>(_removeBookmark);
    on<_UpdateBookmark>(_updateBookmark);
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
      );
      Set<String> allInfoHashes = await getAllInfoHashes();
      emit(
        BookmarkState.loaded(
          bookmarkedTorrents: torrents,
          infoHashes: allInfoHashes,
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
}
