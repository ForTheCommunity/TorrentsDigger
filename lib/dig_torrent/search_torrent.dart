import 'package:flutter/material.dart';
import 'package:torrents_digger/src/rust/api/app.dart';

Future<List<InternalTorrent>> searchTorrent({
  required String torrentName,
  required String source,
  required String filter,
  required String category,
  required String sorting,
}) async {
  debugPrint("$torrentName, $source, $category");
  // calling rust-side to fetch data from torrent sites
  List<InternalTorrent> torrents = await digTorrent(
    torrentName: torrentName,
    source: source,
    filter: filter,
    category: category,
    sorting: sorting,
  );
  return torrents;
}
