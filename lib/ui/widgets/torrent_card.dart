import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/category_bloc/category_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/tags_bloc/tags_bloc.dart';
import 'package:torrents_digger/blocs/default_trackers_bloc/default_trackers_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/database/bookmarks.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/launch_url.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

class TorrentCard extends StatelessWidget {
  final InternalTorrent torrent;
  const TorrentCard({super.key, required this.torrent});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Card(
      color: colors.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.cardSecondaryTextColor.withValues(
            alpha: 0.18,
          ),
          width: 1,
        ),
      ),
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
                BlocBuilder<BookmarkedIhBloc, BookmarkedIhState>(
                  builder: (context, state) {
                    bool isBookmarked = false;

                    state.whenOrNull(
                      loaded: (infoHashes) {
                        isBookmarked = infoHashes.contains(torrent.infoHash);
                      },
                    );

                    return Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
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
                                categoryID: null,
                              );
                            }
                          },
                        ),

                        if (isBookmarked)
                          IconButton(
                            icon: Icon(
                              Icons.new_label_outlined,
                              color: context.appColors.addTagIconColor,
                            ),
                            onPressed: () {
                              _tagPickerDialog(
                                context,
                                infoHash: torrent.infoHash,
                              );
                            },
                          ),
                      ],
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
                const Spacer(),
                PopupMenuButton<String>(
                  tooltip: 'Copy Options',
                  icon: Icon(
                    Icons.copy_rounded,
                    color: colors.torrentCardCopyButtonIconColor,
                    size: 22,
                  ),
                  color: colors.torrentCardCopyMenuBackgroundColor,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colors.torrentCardCopyMenuBorderColor,
                      width: 1.5,
                    ),
                  ),
                  onSelected: (value) async {
                    await _handleCopyAction(context, value);
                  },
                  itemBuilder: (_) {
                    final menuTextColor =
                        colors.torrentCardCopyMenuTextColor;
                    final menuIconColor =
                        colors.torrentCardCopyMenuIconColor;
                    return [
                      PopupMenuItem<String>(
                        value: 'name',
                        child: Row(
                          children: [
                            Icon(
                              Icons.title_rounded,
                              size: 18,
                              color: menuIconColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Copy Name',
                              style: TextStyle(
                                color: menuTextColor,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'magnet',
                        child: Row(
                          children: [
                            Icon(
                              Icons.link_rounded,
                              size: 18,
                              color: menuIconColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Copy Magnet',
                              style: TextStyle(
                                color: menuTextColor,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'info_hash',
                        child: Row(
                          children: [
                            Icon(
                              Icons.tag_rounded,
                              size: 18,
                              color: menuIconColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Copy Info Hash',
                              style: TextStyle(
                                color: menuTextColor,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (torrent.sourceUrl != null &&
                          torrent.sourceUrl!.trim().isNotEmpty)
                        PopupMenuItem<String>(
                          value: 'source_url',
                          child: Row(
                            children: [
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 18,
                                color: menuIconColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Copy Source URL',
                                style: TextStyle(
                                  color: menuTextColor,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'all_details',
                        child: Row(
                          children: [
                            Icon(
                              Icons.copy_all_rounded,
                              size: 18,
                              color: menuIconColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Copy All Details',
                              style: TextStyle(
                                color: menuTextColor,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCopyAction(BuildContext context, String action) async {
    try {
      switch (action) {
        case 'name':
          await Clipboard.setData(ClipboardData(text: torrent.name));
          createSnackBar(
            message: "Torrent name copied to clipboard",
            duration: 2,
          );
          break;

        case 'magnet':
          final processedMagnet = await processMagnetLink(
            unprocessedMagnet: torrent.magnet,
          );
          await Clipboard.setData(ClipboardData(text: processedMagnet));
          createSnackBar(
            message: "Magnet link copied to clipboard",
            duration: 2,
          );
          break;

        case 'info_hash':
          await Clipboard.setData(ClipboardData(text: torrent.infoHash));
          createSnackBar(
            message: "Info hash copied to clipboard",
            duration: 2,
          );
          break;

        case 'source_url':
          if (torrent.sourceUrl != null && torrent.sourceUrl!.isNotEmpty) {
            await Clipboard.setData(ClipboardData(text: torrent.sourceUrl!));
            createSnackBar(
              message: "Source URL copied to clipboard",
              duration: 2,
            );
          }
          break;

        case 'all_details':
          final processedMagnet = await processMagnetLink(
            unprocessedMagnet: torrent.magnet,
          );
          final buffer = StringBuffer()
            ..writeln("Name: ${torrent.name}")
            ..writeln("Size: ${torrent.size}")
            ..writeln("Created: ${torrent.date}")
            ..writeln(
              "Seeders: ${torrent.seeders} | Leechers: ${torrent.leechers}",
            )
            ..writeln("Info Hash: ${torrent.infoHash}");
          if (torrent.sourceUrl != null &&
              torrent.sourceUrl!.trim().isNotEmpty) {
            buffer.writeln("Source: ${torrent.sourceUrl}");
          }
          buffer.write("Magnet: $processedMagnet");

          await Clipboard.setData(ClipboardData(text: buffer.toString()));
          createSnackBar(
            message: "Torrent details copied to clipboard",
            duration: 2,
          );
          break;
      }
    } catch (e) {
      createSnackBar(message: "Failed to copy: $e", duration: 3);
    }
  }

  // Category Picker Dialog
  void _categoryPickerDialog(
    BuildContext context, {
    required bool isBookmarked,
    int? categoryID,
  }) {
    context.read<CategoryBloc>().add(const CategoryEvent.load());
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            final categories = state.whenOrNull(
              loaded: (categoriesList) => categoriesList
                  // removing All Category
                  .where((c) => c.id != 65535)
                  .toList(),
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
                          final bool isCurrentCategory =
                              categoryID == category.id;

                          return ListTile(
                            leading: Icon(
                              isCurrentCategory
                                  ? Icons.folder
                                  : Icons.folder_open,
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
                                // add info hash
                                context.read<BookmarkedIhBloc>().add(
                                  BookmarkedIhEvent.addInfoHash(
                                    infoHash: torrent.infoHash,
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

  // tag picker dialog
  void _tagPickerDialog(
    BuildContext context, {
    required String infoHash,
  }) async {
    final List<InternalBookmarkTag> allTags = await getAllTags();
    final List<int> assignedTagIds = await getAllTagsOfaTorrent(
      infoHash: infoHash,
    );

    if (!context.mounted) return;

    final tagsBloc = context.read<TagsBloc>();
    final bookmarkBloc = context.read<BookmarkBloc>();

    final Set<int> selectedTagIds = assignedTagIds.toSet();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return allTags.isEmpty
                ? AlertDialog(
                    backgroundColor:
                        context.appColors.tagPickerDialogBackgroundColor,
                    content: SizedBox(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "No tags found. Create tags from the Bookmarks screen.",
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: context
                                  .appColors
                                  .tagPickerDialogDoneButtonBackgroundColor,
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
                              'Close',
                              style: TextStyle(
                                color: context
                                    .appColors
                                    .tagPickerDialogDoneButtonTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                // 'No tags found. Create tags from the Bookmarks screen.',
                : AlertDialog(
                    backgroundColor:
                        context.appColors.tagPickerDialogBackgroundColor,
                    title: Text(
                      'Manage Tags',
                      style: TextStyle(
                        color: context.appColors.tagPickerDialogTitleColor,
                      ),
                    ),
                    content: SizedBox(
                      width: double.minPositive,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: allTags.length,
                        itemBuilder: (context, index) {
                          final tag = allTags[index];
                          final bool isSelected = selectedTagIds.contains(
                            tag.id,
                          );
                          return CheckboxListTile(
                            title: Text(
                              tag.name,
                              style: TextStyle(
                                color:
                                    context.appColors.tagPickerDialogTextColor,
                              ),
                            ),
                            value: isSelected,
                            activeColor:
                                context.appColors.tagCheckboxActiveColor,
                            checkColor: context.appColors.tagCheckboxTickColor,
                            onChanged: (checked) {
                              setDialogState(() {
                                if (checked == true) {
                                  selectedTagIds.add(tag.id);
                                } else {
                                  selectedTagIds.remove(tag.id);
                                }
                              });
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
                                  .tagPickerDialogCloseButtonBackgroundColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: context
                                    .appColors
                                    .tagPickerDialogCloseButtonTextColor,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: context
                                  .appColors
                                  .tagPickerDialogDoneButtonBackgroundColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              tagsBloc.add(
                                TagsEvent.updateTags(
                                  infoHash: infoHash,
                                  selectedTagIds: selectedTagIds.toList(),
                                ),
                              );

                              bookmarkBloc.add(
                                BookmarkEvent.loadBookmarks(
                                  categoryID: bookmarkBloc.currentCategoryId,
                                  tagID: bookmarkBloc.currentTagId,
                                ),
                              );

                              Navigator.pop(dialogContext);
                            },
                            child: Text(
                              'Done',
                              style: TextStyle(
                                color: context
                                    .appColors
                                    .tagPickerDialogDoneButtonTextColor,
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
                onTap: () async {
                  var catID = await getCategoryID(infoHash: torrent.infoHash);

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);
                  _categoryPickerDialog(
                    dialogContext,
                    isBookmarked: true,
                    categoryID: catID,
                  );
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
                  // remove info hash
                  context.read<BookmarkedIhBloc>().add(
                    BookmarkedIhEvent.removeInfoHash(
                      infoHash: torrent.infoHash,
                    ),
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
