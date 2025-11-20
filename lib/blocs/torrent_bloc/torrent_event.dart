part of 'torrent_bloc.dart';

@immutable
sealed class TorrentEvents {}

class SearchTorrents extends TorrentEvents {
  final String torrentName;
  final int sourceIndex;
  final int filterIndex;
  final int categoryIndex;
  final int sortingIndex;
  final int? page;

  SearchTorrents({
    required this.torrentName,
    required this.sourceIndex,
    required this.filterIndex,
    required this.categoryIndex,
    required this.sortingIndex,
    this.page,
  });
}
