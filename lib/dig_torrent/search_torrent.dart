import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

Future<(List<InternalTorrent>, int?)> searchTorrent({
  required String torrentName,
  required int sourceIndex,
  required int filterIndex,
  required int categoryIndex,
  required int sortingIndex,
  required int sortingOrderIndex,
  int? page,
}) async {
  // calling rust-side to fetch data from torrent sites
  (List<InternalTorrent>, int?) torrents = await digTorrent(
    torrentName: torrentName,
    sourceIndex: BigInt.from(sourceIndex),
    categoryIndex: BigInt.from(categoryIndex),
    filterIndex: BigInt.from(filterIndex),
    sortingIndex: BigInt.from(sortingIndex),
    sortingOrderIndex: BigInt.from(sortingOrderIndex),
    page: page,
  );
  return torrents;
}
