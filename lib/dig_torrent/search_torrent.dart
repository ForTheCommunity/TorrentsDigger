import 'package:torrents_digger/src/rust/api/app.dart';

Future<List<InternalTorrent>> searchTorrent({
  required String torrentName,
  required String source,
  required String category,
}) async {
  // calling rust-side to fetch data from torrent sites
  List<InternalTorrent> torrents = await digTorrent(
    torrentName: torrentName,
    source: source,
    category: category,
  );
  return torrents;
}
