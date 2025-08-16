import 'package:flutter/cupertino.dart';
import 'package:torrents_digger/src/rust/api/app.dart';

void searchTorrent({
  required String torrentName,
  required String source,
  required String category,
}) async {
  debugPrint(
    "[DART] : SEARCHING TORRENT OF NAME : $torrentName , $source , $category",
  );

  // calling rust-side to fetch data from torrent sites
  List<InternalTorrent> torrents = await digTorrent(
    torrentName: torrentName,
    source: source,
    category: category,
  );

  InternalTorrent tN1 = torrents.first;
  debugPrint("First Torrent in The List -> ${tN1.name}");
}
