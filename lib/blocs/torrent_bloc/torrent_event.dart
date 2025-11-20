part of 'torrent_bloc.dart';

@immutable
sealed class TorrentEvents {}

class SearchTorrents extends TorrentEvents {
  final String torrentName;
  final int sourceIndex;
  final String filter;
  final int categoryIndex;
  final String sorting;
  final int? page;

  SearchTorrents({
    required this.torrentName,
    required this.sourceIndex,
    required this.filter,
    required this.categoryIndex,
    required this.sorting,
    this.page,
  });
}
