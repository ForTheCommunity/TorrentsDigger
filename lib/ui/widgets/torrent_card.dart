import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/category_bloc/category_bloc.dart';
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
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colors.cardSecondaryTextColor.withValues(alpha: 0.16),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Size Capsule Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    torrent.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.cardPrimaryTextColor,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.bookmarksSidebarSelectedTileBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.bookmarksSidebarSelectedTileBorderColor
                          .withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 13,
                        color: colors.bookmarksSidebarSelectedTileTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        torrent.size,
                        style: TextStyle(
                          color: colors.bookmarksSidebarSelectedTileTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Metadata Metric Badges
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Seeders
                _buildMetricBadge(
                  icon: Icons.arrow_upward_rounded,
                  iconColor: Colors.greenAccent[400]!,
                  label: "${torrent.seeders} seeders",
                  textColor: Colors.greenAccent[400]!,
                  backgroundColor: Colors.green.withValues(alpha: 0.12),
                  borderColor: Colors.green.withValues(alpha: 0.25),
                ),

                // Leechers
                _buildMetricBadge(
                  icon: Icons.arrow_downward_rounded,
                  iconColor: Colors.redAccent[200]!,
                  label: "${torrent.leechers} leechers",
                  textColor: Colors.redAccent[200]!,
                  backgroundColor: Colors.red.withValues(alpha: 0.12),
                  borderColor: Colors.red.withValues(alpha: 0.25),
                ),

                // Downloads (only shown if provided by source and not empty/N/A)
                if (torrent.totalDownloads.trim().isNotEmpty &&
                    torrent.totalDownloads != "0" &&
                    torrent.totalDownloads.toUpperCase() != "N/A")
                  _buildMetricBadge(
                    icon: Icons.download_done_rounded,
                    iconColor: colors.cardSecondaryTextColor,
                    label: "${torrent.totalDownloads} downloads",
                    textColor: colors.cardSecondaryTextColor,
                    backgroundColor:
                        colors.cardSecondaryTextColor.withValues(alpha: 0.08),
                    borderColor:
                        colors.cardSecondaryTextColor.withValues(alpha: 0.15),
                  ),

                // Date
                if (torrent.date.isNotEmpty)
                  _buildMetricBadge(
                    icon: Icons.calendar_today_rounded,
                    iconColor: colors.cardSecondaryTextColor,
                    label: torrent.date,
                    textColor: colors.cardSecondaryTextColor,
                    backgroundColor:
                        colors.cardSecondaryTextColor.withValues(alpha: 0.08),
                    borderColor:
                        colors.cardSecondaryTextColor.withValues(alpha: 0.15),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            Divider(
              height: 18,
              thickness: 1,
              color: colors.cardSecondaryTextColor.withValues(alpha: 0.1),
            ),

            // Bottom Action Bar
            Row(
              children: [
                // Prominent Magnet Button
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        colors.bookmarksSidebarSelectedTileBackgroundColor,
                    foregroundColor:
                        colors.bookmarksSidebarSelectedTileTextColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: colors.bookmarksSidebarSelectedTileBorderColor
                            .withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                  ),
                  icon: const SizedBox(
                    width: 18,
                    height: 18,
                    child: MagnetSVG(size: 18),
                  ),
                  label: const Text(
                    "Open Magnet",
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    try {
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

                const Spacer(),

                // Bookmark & Tag
                BlocBuilder<BookmarkedIhBloc, BookmarkedIhState>(
                  builder: (context, state) {
                    bool isBookmarked = false;
                    state.whenOrNull(
                      loaded: (infoHashes) {
                        isBookmarked = infoHashes.contains(torrent.infoHash);
                      },
                    );

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: isBookmarked
                                ? colors.bookmarkedIconColor
                                : colors.bookmarkIconColor,
                            size: 22,
                          ),
                          tooltip: isBookmarked
                              ? "Bookmark Options"
                              : "Add to Bookmarks",
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
                              color: colors.addTagIconColor,
                              size: 20,
                            ),
                            tooltip: "Manage Tags",
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

                // Source Link
                IconButton(
                  icon: Icon(
                    Icons.open_in_new_rounded,
                    color: (torrent.sourceUrl != null &&
                            torrent.sourceUrl!.isNotEmpty)
                        ? colors.sourceUrlAvailableColor
                        : colors.sourceUrlUnAvailableColor,
                    size: 20,
                  ),
                  tooltip: (torrent.sourceUrl != null &&
                          torrent.sourceUrl!.isNotEmpty)
                      ? "Open Source Webpage"
                      : "No Source Webpage",
                  onPressed: () async {
                    if (torrent.sourceUrl != null &&
                        torrent.sourceUrl!.trim().isNotEmpty) {
                      await openUrl(
                        urlType: UrlType.normalLink,
                        url: torrent.sourceUrl!,
                        title: torrent.name,
                        context: context,
                      );
                    } else {
                      createSnackBar(
                        message:
                            "This source doesn't provide a description page for torrents.",
                        duration: 2,
                      );
                    }
                  },
                ),

                // Copy Options Popup Menu
                PopupMenuButton<String>(
                  tooltip: 'Copy Options',
                  icon: Icon(
                    Icons.copy_rounded,
                    color: colors.torrentCardCopyButtonIconColor,
                    size: 20,
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
                    final menuTextColor = colors.torrentCardCopyMenuTextColor;
                    final menuIconColor = colors.torrentCardCopyMenuIconColor;
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
                          torrent.sourceUrl!.trim().isNotEmpty) ...[
                        PopupMenuItem<String>(
                          value: 'open_source_page',
                          child: Row(
                            children: [
                              Icon(
                                Icons.language_rounded,
                                size: 18,
                                color: menuIconColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Open Source Page',
                                style: TextStyle(
                                  color: menuTextColor,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'source_url',
                          child: Row(
                            children: [
                              Icon(
                                Icons.copy_rounded,
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
                      ],
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

  Widget _buildMetricBadge({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          createSnackBar(message: "Info hash copied to clipboard", duration: 2);
          break;

        case 'open_source_page':
          if (torrent.sourceUrl != null &&
              torrent.sourceUrl!.trim().isNotEmpty) {
            await openUrl(
              urlType: UrlType.normalLink,
              url: torrent.sourceUrl!,
              title: torrent.name,
              context: context,
            );
          }
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
                            onPressed: () async {
                              Navigator.pop(dialogContext);

                              try {
                                await updateBookmarkTags(
                                  infoHash: infoHash,
                                  tagIds: selectedTagIds.toList(),
                                );
                                createSnackBar(
                                  message: "Tag Updated...",
                                  duration: 1,
                                );

                                bookmarkBloc.add(
                                  BookmarkEvent.loadBookmarks(
                                    categoryID: bookmarkBloc.currentCategoryId,
                                    tagID: bookmarkBloc.currentTagId,
                                  ),
                                );
                              } catch (e) {
                                createSnackBar(
                                  message: "Error : ${e.toString()}",
                                  duration: 5,
                                );
                              }
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
  final double size;
  const MagnetSVG({super.key, this.size = 25});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/magnet-svgrepo-com.svg",
      semanticsLabel: 'Magnet Link',
      height: size,
      width: size,
      colorFilter: ColorFilter.mode(
        context.appColors.magnetIconColor,
        BlendMode.srcIn,
      ),
    );
  }
}
