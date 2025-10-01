import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/src/rust/api/database/bookmark.dart';

Future<BigInt> torrentBookmark(InternalTorrent torrent) async {
  var result = await bookmarkATorrent(torrent: torrent);
  return result;
}

Future<List<InternalTorrent>> getBookmarks() async {
  return await getAllBookmarks();
}

Future<bool> checkBookmark(String infoHash) async {
  return await checkBookmarkExistence(infoHash: infoHash);
}

Future<bool> removeABookmark(String infoHash) async {
  return await removeBookmark(infoHash: infoHash);
}
