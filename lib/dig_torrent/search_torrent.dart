import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

Future<(List<InternalTorrent>, int?)> searchTorrent({
  required String torrentName,
  // required String source,
  required int sourceIndex,
  required String filter,
  required String category,
  required String sorting,
  int? page,
}) async {
  print("[DART] SOURCE INDEX : $sourceIndex");
  // calling rust-side to fetch data from torrent sites
  (List<InternalTorrent>, int?) torrents = await digTorrent(
    torrentName: torrentName,
    // source: source,
    sourceIndex: BigInt.from(sourceIndex),
    filter: filter,
    category: category,
    sorting: sorting,
    page: page,
  );
  return torrents;
}
