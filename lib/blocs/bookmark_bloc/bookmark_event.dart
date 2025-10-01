part of 'bookmark_bloc.dart';

@immutable
sealed class BookmarkEvent {}

class ToggleBookmarkEvent extends BookmarkEvent {
  final InternalTorrent torrent;

  ToggleBookmarkEvent({required this.torrent});
}

class BookmarkTorrentEvent extends BookmarkEvent {
  final InternalTorrent torrent;

  BookmarkTorrentEvent({required this.torrent});
}

class UnbookmarkTorrentEvent extends BookmarkEvent {
  final String infoHash;

  UnbookmarkTorrentEvent({required this.infoHash});
}

class LoadBookmarkedTorrentsEvent extends BookmarkEvent {}
