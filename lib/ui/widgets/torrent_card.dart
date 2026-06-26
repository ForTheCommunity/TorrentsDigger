import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/category_bloc/category_bloc.dart';
import 'package:torrents_digger/blocs/default_trackers_bloc/default_trackers_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
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

                    state.whenOrNull(
                      loaded: (bookmarkedTorrents, infoHashes, _, _, _) {
                        isBookmarked = infoHashes.contains(torrent.infoHash);
                      },
                    );

                    return IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked
                            ? context.appColors.bookmarkedIconColor
                            : context.appColors.bookmarkIconColor,
                        size: 24,
                      ),
                      onPressed: () {
                        if (isBookmarked) {
                          _bookmarkOptionsDialog(context);
                        } else {
                          _categoryPickerDialog(
                            context,
                            isBookmarked: isBookmarked,
                          );
                        }
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
                const SizedBox(width: 10),
                IconButton(
                  icon:
                      torrent.sourceUrl != null && torrent.sourceUrl!.isNotEmpty
                      ? Icon(
                          Icons.link,
                          color: context.appColors.sourceUrlAvailableColor,
                        )
                      : Icon(
                          Icons.link,
                          color: context.appColors.sourceUrlUnAvailableColor,
                        ),
                  onPressed: () async {
                    if (torrent.sourceUrl != null) {
                      try {
                        createSnackBar(
                          message: "Opening Torrent Description Page....",
                          duration: 2,
                        );
                        openUrl(
                          urlType: UrlType.normalLink,
                          clipboardCopy: false,
                          url: torrent.sourceUrl!,
                        );
                      } catch (e) {
                        createSnackBar(
                          message:
                              "Error Opening Source URL...\nError: ${e.toString}",
                          duration: 10,
                        );
                      }
                    } else {
                      createSnackBar(
                        message:
                            "This source doesn't provide a description page for torrents.",
                        duration: 2,
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

  // Category Picker Dialog
  void _categoryPickerDialog(
    BuildContext context, {
    required bool isBookmarked,
  }) {
    context.read<CategoryBloc>().add(const CategoryEvent.load());
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            final categories = state.whenOrNull(
              loaded: (categoriesList) => categoriesList,
            );

            return AlertDialog(
              backgroundColor:
                  context.appColors.bookmarkCategoryDialogBackgroundColor,
              title: Text(
                'Select Category',
                style: TextStyle(
                  color: context.appColors.bookmarkCategoryDialogTextColor,
                ),
              ),
              content: categories == null || categories.isEmpty
                  ? const Text('No Categories Found')
                  : SizedBox(
                      width: double.minPositive,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return ListTile(
                            leading: Icon(
                              Icons.folder_open,
                              color:
                                  context.appColors.bookmarkCategoryIconColor,
                            ),
                            title: Text(category.name),
                            onTap: () {
                              // change category / Update
                              if (isBookmarked) {
                                int currentlyViewingCategoryID = context
                                    .read<BookmarkBloc>()
                                    .currentCategoryId;

                                context.read<BookmarkBloc>().add(
                                  BookmarkEvent.updateBookmark(
                                    infoHash: torrent.infoHash,
                                    categoryId: category.id,
                                    currenltyViewingCategoryID:
                                        currentlyViewingCategoryID,
                                  ),
                                );

                                createSnackBar(
                                  message: 'Moved to "${category.name}"',
                                  duration: 1,
                                );
                              }
                              // add 2 category / Insert
                              else {
                                context.read<BookmarkBloc>().add(
                                  BookmarkEvent.bookmark(
                                    torrent: torrent,
                                    categoryID: category.id,
                                  ),
                                );
                                createSnackBar(
                                  message:
                                      'Bookmarked under "${category.name}"',
                                  duration: 1,
                                );
                              }

                              Navigator.pop(dialogContext);
                            },
                          );
                        },
                      ),
                    ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: context
                            .appColors
                            .bookmarkCategoryDialogCloseButtonBackgroundColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: context
                              .appColors
                              .bookmarkCategoryDialogCloseButtonTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Bookmark Options Dialog
  void _bookmarkOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              context.appColors.bookmarkCategoryDialogBackgroundColor,
          title: Text(
            'Bookmark Options',
            style: TextStyle(
              color: context.appColors.bookmarkCategoryDialogTextColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.folder_open,
                  color: context.appColors.bookmarkCategoryIconColor,
                ),
                title: Text(
                  'Change Category',
                  style: TextStyle(
                    color: context.appColors.bookmarkCategoryDialogTextColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _categoryPickerDialog(context, isBookmarked: true);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color:
                      context.appColors.bookmarkCategoryDialogRemoveIconColor,
                ),
                title: Text(
                  'Remove Bookmark',
                  style: TextStyle(
                    color: context.appColors.bookmarkCategoryDialogTextColor,
                  ),
                ),
                onTap: () {
                  context.read<BookmarkBloc>().add(
                    BookmarkEvent.removeBookmark(infoHash: torrent.infoHash),
                  );
                  createSnackBar(message: 'Bookmark Removed', duration: 1);
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: context
                        .appColors
                        .bookmarkCategoryDialogCloseButtonBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: context
                          .appColors
                          .bookmarkCategoryDialogCloseButtonTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
