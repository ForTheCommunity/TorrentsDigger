import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmarks_stats_bloc/bookmarks_stats_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/category_bloc/category_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/tags_bloc/tags_bloc.dart';
import 'package:torrents_digger/blocs/default_trackers_bloc/default_trackers_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/database/bookmarks.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/chip_grid_widgets.dart';
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

  // ===========================================================================
  // DIALOGS: Category Picker, Tag Picker, Bookmark Options
  // ===========================================================================

  Widget _buildDialogEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: iconColor.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // 1. Category Picker Dialog (Sheet / Flat style)
  void _categoryPickerDialog(
    BuildContext context, {
    required bool isBookmarked,
    int? categoryID,
  }) {
    context.read<CategoryBloc>().add(const CategoryEvent.load());
    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = context.appColors;
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            final categories = state.whenOrNull(
              loaded: (categoriesList) => categoriesList
                  .where((c) => c.id != 65535)
                  .toList(),
            );

            void onSelectCategory(InternalBookmarkCategory category) {
              if (isBookmarked) {
                int currentlyViewingCategoryID =
                    context.read<BookmarkBloc>().currentCategoryId;

                context.read<BookmarkBloc>().add(
                      BookmarkEvent.updateBookmark(
                        infoHash: torrent.infoHash,
                        categoryId: category.id,
                        currenltyViewingCategoryID:
                            currentlyViewingCategoryID,
                      ),
                    );
                context.read<BookmarksStatsBloc>().add(
                      const BookmarksStatsEvent.load(),
                    );

                createSnackBar(
                  message: 'Moved to "${category.name}"',
                  duration: 1,
                );
              } else {
                context.read<BookmarkBloc>().add(
                      BookmarkEvent.bookmark(
                        torrent: torrent,
                        categoryID: category.id,
                      ),
                    );
                context.read<BookmarksStatsBloc>().add(
                      const BookmarksStatsEvent.load(),
                    );
                context.read<BookmarkedIhBloc>().add(
                      BookmarkedIhEvent.addInfoHash(
                        infoHash: torrent.infoHash,
                      ),
                    );
                createSnackBar(
                  message: 'Bookmarked under "${category.name}"',
                  duration: 1,
                );
              }
              Navigator.pop(dialogContext);
            }

            return AlertDialog(
              backgroundColor: colors.bookmarkCategoryDialogBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              actionsPadding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.bookmarkCategoryIconColor
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.folder_copy_rounded,
                      color: colors.bookmarkCategoryIconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Category',
                          style: TextStyle(
                            color: colors.bookmarkCategoryDialogTextColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          torrent.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.cardSecondaryTextColor
                                .withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.cardSecondaryTextColor
                          .withValues(alpha: 0.7),
                      size: 20,
                    ),
                    tooltip: 'Close',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
              content: SizedBox(
                width: 390,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 330),
                  child: categories == null || categories.isEmpty
                      ? _buildDialogEmptyState(
                          icon: Icons.folder_off_outlined,
                          title: 'No Categories Found',
                          subtitle:
                              'Create a category below to organize your bookmarks.',
                          iconColor: colors.cardSecondaryTextColor,
                          titleColor: colors.bookmarkCategoryDialogTextColor,
                          subtitleColor: colors.cardSecondaryTextColor,
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: colors.bookmarksStatsBorderColor
                                .withValues(alpha: 0.3),
                          ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final bool isCurrent =
                                categoryID == category.id;

                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => onSelectCategory(category),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCurrent
                                          ? Icons.folder_rounded
                                          : Icons.folder_outlined,
                                      size: 18,
                                      color: isCurrent
                                          ? colors.bookmarkCategoryIconColor
                                          : colors.cardSecondaryTextColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isCurrent
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: colors
                                              .bookmarkCategoryDialogTextColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCurrent
                                            ? colors.bookmarkCategoryIconColor
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isCurrent
                                              ? colors.bookmarkCategoryIconColor
                                              : colors.cardSecondaryTextColor
                                                  .withValues(alpha: 0.5),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isCurrent
                                          ? const Icon(
                                              Icons.check,
                                              size: 12,
                                              color: Colors.black,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: colors.bookmarkCategoryIconColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        createItemDialog(
                          context,
                          title: "New Category",
                          hintText: "Category Name",
                          emptyErrorMessage:
                              "Category Name can't be empty...",
                          onCreate: (name) =>
                              context.read<CategoryBloc>().add(
                                    CategoryEvent.create(
                                      newCategoryName: name,
                                    ),
                                  ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'New Category',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: colors
                            .bookmarkCategoryDialogCloseButtonBackgroundColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: colors
                              .bookmarkCategoryDialogCloseButtonTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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

  // 2. Manage Tags Dialog
  void _tagPickerDialog(
    BuildContext context, {
    required String infoHash,
  }) async {
    final List<int> assignedTagIds = await getAllTagsOfaTorrent(
      infoHash: infoHash,
    );

    if (!context.mounted) return;

    context.read<TagsBloc>().add(const TagsEvent.load());
    final bookmarkBloc = context.read<BookmarkBloc>();
    final bookmarksStatsBloc = context.read<BookmarksStatsBloc>();

    final Set<int> selectedTagIds = assignedTagIds.toSet();
    String? lastCreatedTagName;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = context.appColors;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocConsumer<TagsBloc, TagsState>(
              listener: (context, state) {
                state.whenOrNull(
                  loaded: (tags) {
                    if (lastCreatedTagName != null) {
                      final newTag = tags
                          .cast<InternalBookmarkTag?>()
                          .firstWhere(
                            (t) => t?.name == lastCreatedTagName,
                            orElse: () => null,
                          );
                      if (newTag != null) {
                        setDialogState(() {
                          selectedTagIds.add(newTag.id);
                        });
                        lastCreatedTagName = null;
                      }
                    }
                  },
                );
              },
              builder: (context, state) {
                final allTags = state.whenOrNull(
                  loaded: (tags) => tags.where((t) => t.id != 65535).toList(),
                );

                return AlertDialog(
                  backgroundColor: colors.tagPickerDialogBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: colors.bookmarksStatsBorderColor
                          .withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  actionsPadding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.bookmarksStatsIconColor
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.local_offer_rounded,
                          color: colors.bookmarksStatsIconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage Tags',
                              style: TextStyle(
                                color: colors.tagPickerDialogTitleColor,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              torrent.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colors.cardSecondaryTextColor
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.cardSecondaryTextColor
                              .withValues(alpha: 0.7),
                          size: 20,
                        ),
                        tooltip: 'Close',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: 390,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 330),
                      child: allTags == null || allTags.isEmpty
                          ? _buildDialogEmptyState(
                              icon: Icons.sell_outlined,
                              title: 'No Tags Found',
                              subtitle:
                                  'Create a tag below to attach it to this torrent.',
                              iconColor: colors.cardSecondaryTextColor,
                              titleColor: colors.tagPickerDialogTextColor,
                              subtitleColor: colors.cardSecondaryTextColor,
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: allTags.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final tag = allTags[index];
                                final bool isSelected =
                                    selectedTagIds.contains(tag.id);

                                return Material(
                                  color: isSelected
                                      ? colors.bookmarksStatsIconColor
                                          .withValues(alpha: 0.12)
                                      : colors.cardColor
                                          .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      setDialogState(() {
                                        if (isSelected) {
                                          selectedTagIds.remove(tag.id);
                                        } else {
                                          selectedTagIds.add(tag.id);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? colors.bookmarksStatsIconColor
                                              : colors
                                                  .bookmarksStatsBorderColor
                                                  .withValues(alpha: 0.4),
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.label_rounded,
                                            color: isSelected
                                                ? colors
                                                    .bookmarksStatsIconColor
                                                : colors
                                                    .cardSecondaryTextColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              tag.name,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: colors
                                                    .tagPickerDialogTextColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? colors
                                                      .tagCheckboxActiveColor
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: isSelected
                                                    ? colors
                                                        .tagCheckboxActiveColor
                                                    : colors
                                                        .cardSecondaryTextColor
                                                        .withValues(alpha: 0.5),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: isSelected
                                                ? Icon(
                                                    Icons.check_rounded,
                                                    size: 16,
                                                    color: colors
                                                        .tagCheckboxTickColor,
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: colors.bookmarksStatsIconColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            createItemDialog(
                              context,
                              title: "New Tag",
                              hintText: "Tag Name",
                              emptyErrorMessage:
                                  "Tag Name can't be empty...",
                              onCreate: (name) {
                                lastCreatedTagName = name;
                                context.read<TagsBloc>().add(
                                      TagsEvent.create(newTagName: name),
                                    );
                              },
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text(
                            'New Tag',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: colors
                                    .tagPickerDialogCloseButtonBackgroundColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: colors
                                      .tagPickerDialogCloseButtonTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: colors
                                    .tagPickerDialogDoneButtonBackgroundColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 9,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
                                    message: "Tags Updated...",
                                    duration: 1,
                                  );

                                  bookmarkBloc.add(
                                    BookmarkEvent.loadBookmarks(
                                      categoryID:
                                          bookmarkBloc.currentCategoryId,
                                      tagID: bookmarkBloc.currentTagId,
                                    ),
                                  );
                                  bookmarksStatsBloc.add(
                                    const BookmarksStatsEvent.load(),
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
                                  color: colors
                                      .tagPickerDialogDoneButtonTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // 3. Bookmark Options Dialog
  void _bookmarkOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = context.appColors;

        void onChangeCategory() async {
          var catID = await getCategoryID(infoHash: torrent.infoHash);

          if (!dialogContext.mounted) return;

          Navigator.pop(dialogContext);
          _categoryPickerDialog(
            dialogContext,
            isBookmarked: true,
            categoryID: catID,
          );
        }

        void onRemoveBookmark() {
          context.read<BookmarkBloc>().add(
                BookmarkEvent.removeBookmark(infoHash: torrent.infoHash),
              );
          context.read<BookmarksStatsBloc>().add(
                const BookmarksStatsEvent.load(),
              );
          context.read<BookmarkedIhBloc>().add(
                BookmarkedIhEvent.removeInfoHash(
                  infoHash: torrent.infoHash,
                ),
              );
          createSnackBar(message: 'Bookmark Removed', duration: 1);
          Navigator.pop(dialogContext);
        }

        return AlertDialog(
          backgroundColor: colors.bookmarkCategoryDialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          actionsPadding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      colors.bookmarkCategoryIconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bookmark_rounded,
                  color: colors.bookmarkCategoryIconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bookmark Options',
                      style: TextStyle(
                        color: colors.bookmarkCategoryDialogTextColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      torrent.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.cardSecondaryTextColor
                            .withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colors.cardSecondaryTextColor.withValues(alpha: 0.7),
                  size: 20,
                ),
                tooltip: 'Close',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ],
          ),
          content: SizedBox(
            width: 390,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: colors.cardColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onChangeCategory,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.bookmarksStatsBorderColor
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.bookmarkCategoryIconColor
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.folder_open_rounded,
                              size: 20,
                              color: colors.bookmarkCategoryIconColor,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Change Category',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        colors.bookmarkCategoryDialogTextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Move this torrent to another folder',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.cardSecondaryTextColor
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: colors.cardSecondaryTextColor
                                .withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  color: colors.bookmarkCategoryDialogRemoveIconColor
                      .withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onRemoveBookmark,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.bookmarkCategoryDialogRemoveIconColor
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors
                                  .bookmarkCategoryDialogRemoveIconColor
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: colors
                                  .bookmarkCategoryDialogRemoveIconColor,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Remove Bookmark',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: colors
                                        .bookmarkCategoryDialogRemoveIconColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Delete from your saved library',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.cardSecondaryTextColor
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: colors.bookmarkCategoryDialogRemoveIconColor
                                .withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: colors
                      .bookmarkCategoryDialogCloseButtonBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: colors.bookmarkCategoryDialogCloseButtonTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
