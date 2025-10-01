import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:torrents_digger/database/bookmarks.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

part 'bookmark_event.dart';
part 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  BookmarkBloc() : super(BookmarkInitialState()) {
    on<LoadBookmarkedTorrentsEvent>(_onLoadBookmarkedTorrents);
    on<ToggleBookmarkEvent>(_onToggleBookmark);
    on<BookmarkTorrentEvent>(_onBookmarkTorrent);
    on<UnbookmarkTorrentEvent>(_onRemoveBookmarkedTorrent);
  }

  Future<void> _onLoadBookmarkedTorrents(
    LoadBookmarkedTorrentsEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(BookmarksLoadingState());
    try {
      final torrents = await getBookmarks();
      final infoHashes = torrents.map((t) => t.infoHash).toSet();
      emit(
        BookmarksLoadedState(
          bookmarkedTorrents: torrents,
          bookmarkedInfoHashes: infoHashes,
        ),
      );
    } catch (e) {
      emit(BookmarksLoadFailedState(error: e.toString()));
    }
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    final currentState = state;
    if (currentState is BookmarksLoadedState) {
      if (currentState.bookmarkedInfoHashes.contains(event.torrent.infoHash)) {
        add(UnbookmarkTorrentEvent(infoHash: event.torrent.infoHash));
      } else {
        add(BookmarkTorrentEvent(torrent: event.torrent));
      }
    }
  }

  Future<void> _onBookmarkTorrent(
    BookmarkTorrentEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    await torrentBookmark(event.torrent);
    // Reload bookmarks to reflect the change
    add(LoadBookmarkedTorrentsEvent());
  }

  Future<void> _onRemoveBookmarkedTorrent(
    UnbookmarkTorrentEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    await removeABookmark(event.infoHash);
    // Reload bookmarks to reflect the change
    add(LoadBookmarkedTorrentsEvent());
  }
}
