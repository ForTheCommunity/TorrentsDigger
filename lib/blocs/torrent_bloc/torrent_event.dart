part of 'torrent_bloc.dart';

@immutable
sealed class TorrentEvents {}

class SearchTorrents extends TorrentEvents {
  final String torrentName;
  final int sourceIndex;
  final int filterIndex;
  final int categoryIndex;
  final String sorting;
  final int? page;

  SearchTorrents({
    required this.torrentName,
    required this.sourceIndex,
    required this.filterIndex,
    required this.categoryIndex,
    required this.sorting,
    this.page,
  });
}
