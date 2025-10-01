part of 'bookmark_bloc.dart';

@immutable
sealed class BookmarkState {}

final class BookmarkInitialState extends BookmarkState {}

final class BookmarksLoadingState extends BookmarkState {}

final class BookmarksLoadedState extends BookmarkState {
  final List<InternalTorrent> bookmarkedTorrents;
  final Set<String> bookmarkedInfoHashes;
  BookmarksLoadedState({
    required this.bookmarkedTorrents,
    required this.bookmarkedInfoHashes,
  });
}

final class BookmarksLoadFailedState extends BookmarkState {
  final String error;
  BookmarksLoadFailedState({required this.error});
}
