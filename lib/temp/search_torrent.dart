import 'package:flutter/cupertino.dart';
import 'package:torrents_digger/src/rust/api/app.dart';

void searchTorrent({required String torrentName}) {
  debugPrint("SEARCHING TORRENT OF NAME : $torrentName");

  // calling rust to fetch data from torrent sites
  digTorrent(torrentName: torrentName);
}
