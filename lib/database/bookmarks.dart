import 'dart:typed_data';

import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/src/rust/api/database/bookmark.dart';

Future<BigInt> torrentBookmark(InternalTorrent torrent, int categoryId) async {
  var result = await bookmarkATorrent(torrent: torrent, categoryId: categoryId);
  return result;
}

Future<void> bookmarkTorrentManually({
  required String torrentName,
  required String infoHash,
  required String magnetLink,
  required String torrentSize,
  required String creationDate,
  required String seeders,
  required String leechers,
  required String totalDownloads,
  required String? sourceUrl,
  required int categoryId,
  required List<int> tagIds,
}) async {
  return await insertBookmarkManually(
    torrent: InternalTorrent(
      infoHash: infoHash,
      name: torrentName,
      magnet: magnetLink,
      size: torrentSize,
      date: creationDate,
      seeders: seeders,
      leechers: leechers,
      totalDownloads: totalDownloads,
      sourceUrl: sourceUrl,
    ),
    categoryId: categoryId,
    tagIds: tagIds,
  );
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

Future<void> updateBookmarkTags({
  required String infoHash,
  required List<int> tagIds,
}) async {
  await updateTorrentTags(infoHash: infoHash, tagIds: tagIds);
}
