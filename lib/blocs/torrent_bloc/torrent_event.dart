part of 'torrent_bloc.dart';

@immutable
sealed class TorrentEvents {}

class SearchTorrents extends TorrentEvents {
  final String torrentName;
  // final String source;
  final int sourceIndex;
  final String filter;
  final String category;
  final String sorting;
  final int? page;

  SearchTorrents({
    required this.torrentName,
    // required this.source,
    required this.sourceIndex,
    required this.filter,
    required this.category,
    required this.sorting,
    this.page,
  });
}
