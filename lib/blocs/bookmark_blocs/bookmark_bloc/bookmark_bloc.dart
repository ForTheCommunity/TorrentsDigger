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
  int currentTagId = 0;
  static const int _defaultLimit = 10;

  BookmarkBloc() : super(_Initial()) {
    on<_LoadBookmarks>(_loadBookmarks);
    on<_Bookmark>(_bookmark);
    on<_RemoveBookmark>(_removeBookmark);
    on<_UpdateBookmark>(_updateBookmark);
    on<_LoadMoreBookmarks>(_loadMoreBookmarks);
    on<_SearchBookmarkedTorrents>(_searchBookmarkedTorrents);
  }

  Future<void> _loadBookmarks(
    _LoadBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      currentCategoryId = event.categoryID;
      currentTagId = event.tagID;

      emit(BookmarkState.loading());
      List<InternalTorrent> torrents = await getBookmarks(
        categoryId: event.categoryID,
        tagId: event.tagID,
        limit: _defaultLimit,
        offset: 0,
      );

      emit(
        BookmarkState.loaded(
          bookmarkedTorrents: torrents,
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
      add(
        BookmarkEvent.loadBookmarks(
          categoryID: currentCategoryId,
          tagID: currentTagId,
        ),
      );
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
    }
  }

  Future<void> _removeBookmark(
    _RemoveBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      await removeABookmark(infoHash: event.infoHash);
      // Reloading bookmarks to reflect the change
      add(
        BookmarkEvent.loadBookmarks(
          categoryID: currentCategoryId,
          tagID: currentTagId,
        ),
      );
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
          tagID: currentTagId,
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
        tagId: currentTagId,
        limit: _defaultLimit,
        offset: currentState.currentOffset,
      );

      emit(
        BookmarkState.loaded(
          bookmarkedTorrents: [
            ...currentState.bookmarkedTorrents,
            ...newTorrents,
          ],
          currentOffset: currentState.currentOffset + newTorrents.length,
          hasMore: newTorrents.length == _defaultLimit,
        ),
      );
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }

  Future<void> _searchBookmarkedTorrents(
    _SearchBookmarkedTorrents event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      final List<InternalTorrent> torrents = await searchBookmarks(
        text: event.text,
      );
      emit(
        BookmarkState.loaded(
          bookmarkedTorrents: torrents,
          currentOffset: 0,
          hasMore: false,
        ),
      );
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }
}

class BookmarkedIhBloc extends Bloc<BookmarkedIhEvent, BookmarkedIhState> {
  BookmarkedIhBloc() : super(_InitialIhState()) {
    on<_LoadInfoHashes>(_loadInfoHashes);
    on<_AddInfoHash>(_addInfoHash);
    on<_RemoveInfoHash>(_removeInfoHash);
  }

  Future<void> _loadInfoHashes(
    _LoadInfoHashes event,
    Emitter<BookmarkedIhState> emit,
  ) async {
    try {
      Set<String> allInfoHashes = await getAllInfoHashes();
      emit(BookmarkedIhState.loaded(infoHashes: allInfoHashes));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }

  void _addInfoHash(_AddInfoHash event, Emitter<BookmarkedIhState> emit) {
    state.whenOrNull(
      loaded: (infoHashes) {
        final newHashes = Set<String>.from(infoHashes)..add(event.infoHash);
        emit(BookmarkedIhState.loaded(infoHashes: newHashes));
      },
    );
  }

  void _removeInfoHash(_RemoveInfoHash event, Emitter<BookmarkedIhState> emit) {
    state.whenOrNull(
      loaded: (infoHashes) {
        final newHashes = Set<String>.from(infoHashes)..remove(event.infoHash);
        emit(BookmarkedIhState.loaded(infoHashes: newHashes));
      },
    );
  }
}
