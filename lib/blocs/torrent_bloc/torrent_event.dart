part of 'torrent_bloc.dart';

@immutable
sealed class TorrentEvents {}

class SearchTorrents extends TorrentEvents {
  final String torrentName;
  final int sourceIndex;
  final int categoryIndex;
  final int filterIndex;
  final int sortingIndex;
  final int sortingOrderIndex;
  final int? page;

  SearchTorrents({
    required this.torrentName,
    required this.sourceIndex,
    required this.categoryIndex,
    required this.filterIndex,
    required this.sortingIndex,
    required this.sortingOrderIndex,
    this.page,
  });
}
