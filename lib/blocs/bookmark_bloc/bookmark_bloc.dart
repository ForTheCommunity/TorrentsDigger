import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:torrents_digger/configs/extensions.dart';
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
    final normalizedDate = normalizeTorrentDate(event.torrent.date);

    final torrent = event.torrent.withDate(normalizedDate);

    await torrentBookmark(torrent);
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

// some checks before before bookmarking.
// some source provides torrent creation dates in
// these formats |10 mins ago|, |Today 06:00|, etc.
String normalizeTorrentDate(String rawDate) {
  final date = rawDate.toLowerCase();

  final relativeRegex = RegExp(
    r'(\d+(\.\d+)?)\s+'
    r'(min|mins|minute|minutes|hour|hours|day|days|week|weeks|month|months|year|years)'
    r'\s+ago',
    caseSensitive: false,
  );

  DateTime resolvedDate = DateTime.now();

  if (date.contains('y-day') || date.contains('yesterday')) {
    resolvedDate = resolvedDate.subtract(const Duration(days: 1));
  } else if (date.contains('today') || date.contains('just now')) {
    // keep current date
  } else {
    final match = relativeRegex.firstMatch(date);

    if (match != null) {
      final value = double.parse(match.group(1)!);
      final unit = match.group(3)!;

      if (unit.startsWith('min')) {
        resolvedDate = resolvedDate.subtract(Duration(minutes: value.round()));
      } else if (unit.startsWith('hour')) {
        resolvedDate = resolvedDate.subtract(Duration(hours: value.round()));
      } else if (unit.startsWith('day')) {
        resolvedDate = resolvedDate.subtract(Duration(days: value.round()));
      } else if (unit.startsWith('week')) {
        resolvedDate = resolvedDate.subtract(
          Duration(days: (value * 7).round()),
        );
      } else if (unit.startsWith('month')) {
        resolvedDate = resolvedDate.subtract(
          Duration(days: (value * 30).round()),
        );
      } else if (unit.startsWith('year')) {
        resolvedDate = resolvedDate.subtract(
          Duration(days: (value * 365).round()),
        );
      }
    }
  }

  return "${resolvedDate.year}-${resolvedDate.month.toString().padLeft(2, '0')}-${resolvedDate.day.toString().padLeft(2, '0')}";
}
