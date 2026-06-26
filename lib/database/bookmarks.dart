import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/src/rust/api/database/bookmark.dart';

Future<BigInt> torrentBookmark(InternalTorrent torrent, int categoryId) async {
  var result = await bookmarkATorrent(torrent: torrent, categoryId: categoryId);
  return result;
}

Future<bool> removeABookmark(String infoHash) async {
  return await removeBookmark(infoHash: infoHash);
}

Future<int?> getCategoryID(String infoHash) async {
  return await getCategoryIdFromIH(infoHash: infoHash);
}
