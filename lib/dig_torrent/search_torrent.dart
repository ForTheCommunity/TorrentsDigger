import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

Future<(List<InternalTorrent>, int?)> searchTorrent({
  required String torrentName,
  required int sourceIndex,
  required int filterIndex,
  required int categoryIndex,
  required String sorting,
  int? page,
}) async {
  // calling rust-side to fetch data from torrent sites
  (List<InternalTorrent>, int?) torrents = await digTorrent(
    torrentName: torrentName,
    sourceIndex: BigInt.from(sourceIndex),
    filterIndex: BigInt.from(filterIndex),
    categoryIndex: BigInt.from(categoryIndex),
    sorting: sorting,
    page: page,
  );
  return torrents;
}
