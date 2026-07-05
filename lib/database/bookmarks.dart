import 'dart:typed_data';

import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/src/rust/api/database/bookmark.dart';

Future<BigInt> torrentBookmark(InternalTorrent torrent, int categoryId) async {
  var result = await bookmarkATorrent(torrent: torrent, categoryId: categoryId);
  return result;
}

Future<bool> removeABookmark({required String infoHash}) async {
  return await removeBookmark(infoHash: infoHash);
}

Future<int?> getCategoryID({required String infoHash}) async {
  return await getCategoryIdFromIH(infoHash: infoHash);
}

Future<List<InternalBookmarkTag>> getAllTags() async {
  return await getBookmarksTags();
}

Future<Uint16List> getAllTagsOfaTorrent({required String infoHash}) async {
  var allTags = await getTagsOfTorrent(infoHash: infoHash);
  return allTags;
}
