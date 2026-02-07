import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:torrents_digger/blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/blocs/default_trackers_bloc/default_trackers_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/launch_url.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

class TorrentCard extends StatelessWidget {
  final InternalTorrent torrent;
  const TorrentCard({super.key, required this.torrent});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.appColors.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              torrent.name,
              style: TextStyle(
                color: context.appColors.cardPrimaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16,
                  color: context.appColors.cardSecondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  torrent.size,
                  style: TextStyle(
                    color: context.appColors.cardSecondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.date_range_sharp,
                  size: 20,
                  color: context.appColors.cardSecondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Created at : ${torrent.date}',
                  style: TextStyle(
                    color: context.appColors.cardSecondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.upload_sharp,
                  size: 20,
                  color: context.appColors.seedersIconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Seeders : ${torrent.seeders}',
                  style: TextStyle(
                    color: context.appColors.seedersTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.download,
                  size: 20,
                  color: context.appColors.leechersIconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Leechers : ${torrent.leechers}',
                  style: TextStyle(
                    color: context.appColors.leechersTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.download_for_offline,
                  size: 20,
                  color: context.appColors.cardSecondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Total Downloads : ${torrent.totalDownloads}',
                  style: TextStyle(
                    color: context.appColors.cardSecondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                BlocBuilder<BookmarkBloc, BookmarkState>(
                  builder: (context, state) {
                    bool isBookmarked = false;
                    if (state is BookmarksLoadedState) {
                      isBookmarked = state.bookmarkedInfoHashes.contains(
                        torrent.infoHash,
                      );
                    }

                    return IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked
                            ? context.appColors.bookmarkedIconColor
                            : context.appColors.bookmarkIconColor,
                        size: 24,
                      ),
                      onPressed: () {
                        context.read<BookmarkBloc>().add(
                          ToggleBookmarkEvent(torrent: torrent),
                        );
                        createSnackBar(
                          message: isBookmarked
                              ? "Bookmark Removed"
                              : "Torrent Bookmarked",
                          duration: 1,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const MagnetSVG(),
                  onPressed: () async {
                    try {
                      // appending Default Tracker List to Magnet link.
                      final processedMagnetLink = await processMagnetLink(
                        unprocessedMagnet: torrent.magnet,
                      );

                      openUrl(
                        urlType: UrlType.magentLink,
                        clipboardCopy: true,
                        url: processedMagnetLink,
                      );
                    } catch (e) {
                      createSnackBar(
                        message:
                            "Error Processing Magnet Link...\nError: ${e.toString}",
                        duration: 10,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MagnetSVG extends StatelessWidget {
  const MagnetSVG({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/magnet-svgrepo-com.svg",
      semanticsLabel: 'Magnet Link',
      height: 25,
      width: 25,
      colorFilter: ColorFilter.mode(
        context.appColors.magnetIconColor,
        BlendMode.srcIn,
      ),
    );
  }
}
