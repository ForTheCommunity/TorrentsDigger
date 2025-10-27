import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:url_launcher/url_launcher.dart';

class TorrentCard extends StatelessWidget {
  final InternalTorrent torrent;
  const TorrentCard({super.key, required this.torrent});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardColor,
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
                color: AppColors.cardPrimaryTextColor,
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
                  color: AppColors.cardSecondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  torrent.size,
                  style: TextStyle(color: AppColors.cardSecondaryTextColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.date_range_sharp,
                  size: 20,
                  color: AppColors.cardSecondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Created at : ${torrent.date}',
                  style: TextStyle(
                    color: AppColors.cardSecondaryTextColor,
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
                  color: AppColors.seedersIconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Seeders : ${torrent.seeders}',
                  style: TextStyle(
                    color: AppColors.seedersTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.download,
                  size: 20,
                  color: AppColors.leechersIconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Leechers : ${torrent.leechers}',
                  style: TextStyle(
                    color: AppColors.leechersTextColor,
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
                  color: AppColors.cardSecondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Total Downloads : ${torrent.totalDownloads}',
                  style: TextStyle(
                    color: AppColors.cardSecondaryTextColor,
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
                            ? AppColors.bookmarkedIconColor
                            : AppColors.bookmarkIconColor,
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
                TextButton(
                  onPressed: () async {
                    final Uri magnetUri = Uri.parse(torrent.magnet);
                    await Clipboard.setData(
                      ClipboardData(text: magnetUri.toString()),
                    );
                    createSnackBar(
                      message:
                          "Magnet Link Copied to Clipboard.\nOpening Torrent Downloader...",
                      duration: 1,
                    );

                    await Future.delayed(const Duration(seconds: 2));

                    if (!await launchUrl(magnetUri)) {
                      createSnackBar(
                        message:
                            'Unable to open torrent downloader.\nInstall Torrent App.',
                        duration: 2,
                      );
                    }
                  },

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/magnet-svgrepo-com.png",
                        width: Platform.isAndroid ? 25 : 30,
                        height: Platform.isAndroid ? 25 : 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
