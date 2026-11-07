import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmarks_stats_bloc/bookmarks_stats_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/category_bloc/category_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/tags_bloc/tags_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/routes/routes_name.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/chip_grid_widgets.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/expandable_torrent_card.dart';
import 'package:torrents_digger/ui/widgets/floating_action_buttons.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  static const int _allCategoriesId = 65535;
  static const int _allTagsId = 65535;

  int? selectedCategoryId = _allCategoriesId;
  int? selectedTagId = _allTagsId;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _sidebarScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Search state
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  // View preferences
  bool _showSidebar = true;
  bool _allCardsView =
      false; // false = compact rows (expand on click), true = full cards

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const CategoryEvent.load());
    context.read<TagsBloc>().add(const TagsEvent.load());
    context.read<BookmarksStatsBloc>().add(const BookmarksStatsEvent.load());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Fire when within 200px of the bottom
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      context.read<BookmarkBloc>().add(const BookmarkEvent.loadMoreBookmarks());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _sidebarScrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _reloadBookmarks() {
    context.read<BookmarkBloc>().add(
      BookmarkEvent.loadBookmarks(
        categoryID: selectedCategoryId ?? _allCategoriesId,
        tagID: selectedTagId ?? _allTagsId,
      ),
    );
    context.read<BookmarksStatsBloc>().add(const BookmarksStatsEvent.load());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            state.whenOrNull(
              loaded: (categoriesList) {
                if (selectedCategoryId != null &&
                    selectedCategoryId != _allCategoriesId &&
                    !categoriesList.any((c) => c.id == selectedCategoryId)) {
                  setState(() {
                    selectedCategoryId = _allCategoriesId;
                  });
                }
                _reloadBookmarks();
              },
            );
          },
        ),
        BlocListener<TagsBloc, TagsState>(
          listener: (context, state) {
            state.whenOrNull(
              loaded: (tagsList) {
                if (selectedTagId != null &&
                    selectedTagId != _allTagsId &&
                    !tagsList.any((t) => t.id == selectedTagId)) {
                  setState(() {
                    selectedTagId = _allTagsId;
                  });
                }
                _reloadBookmarks();
              },
            );
          },
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          return Scaffold(
            key: _scaffoldKey,
            appBar: _buildAppBar(context, isWide: isWide),
            drawer: !isWide
                ? Drawer(
                    backgroundColor:
                        context.appColors.bookmarksSidebarBackgroundColor,
                    child: SafeArea(
                      child: _buildSidebar(context, isMobileDrawer: true),
                    ),
                  )
                : null,
            floatingActionButton: FloatingActionsButtons(
              scrollToTop: true,
              enableAddTorrent: true,
              enableBookmarks: false,
              enableCustoms: true,
              enableSettings: true,
              scrollController: _scrollController,
            ),
            body: SafeArea(
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_showSidebar) ...[
                          SizedBox(
                            width: 270,
                            child:
                                _buildSidebar(context, isMobileDrawer: false),
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color:
                                context.appColors.bookmarksSidebarDividerColor,
                          ),
                        ],
                        Expanded(child: _buildTorrentsPane(context)),
                      ],
                    )
                  : _buildTorrentsPane(context),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    required bool isWide,
  }) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          _isSearching ? Icons.close : Icons.arrow_back,
          color: context.appColors.appBarBackButtonIconColor,
        ),
        iconSize: 28,
        onPressed: () {
          if (_isSearching) {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
            _reloadBookmarks();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.amber, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Search bookmarks by torrent name or info hash',
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: context.appColors.searchBookmarksPlaceholderTextColor,
                ),
                border: InputBorder.none,
              ),
              onChanged: (searchQueryText) {
                final searchQuery = searchQueryText.trim();
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 350), () {
                  if (searchQuery.isEmpty) {
                    _reloadBookmarks();
                  } else {
                    context.read<BookmarkBloc>().add(
                      BookmarkEvent.searchBookmarkedTorrents(text: searchQuery),
                    );
                  }
                });
              },
            )
          : Text(
              'Bookmarks',
              style: TextStyle(
                color: context.appColors.appBarTextColor,
                letterSpacing: 2,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
      actions: [
        if (!_isSearching) ...[
          IconButton(
            icon: Icon(
              Icons.search,
              size: 26,
              color: context.appColors.searchBookmarksIconColor,
            ),
            tooltip: "Search Bookmarks",
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          IconButton(
            icon: Icon(
              isWide
                  ? (_showSidebar
                      ? Icons.view_sidebar
                      : Icons.view_sidebar_outlined)
                  : Icons.view_sidebar_outlined,
              size: 24,
              color: context.appColors.bookmarksViewSidebarIconColor,
            ),
            tooltip: isWide
                ? (_showSidebar
                    ? "Hide Categories & Tags"
                    : "Show Categories & Tags")
                : "Open Library & Tags",
            onPressed: () {
              if (isWide) {
                setState(() {
                  _showSidebar = !_showSidebar;
                });
              } else {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
          ),
          IconButton(
            icon: Icon(
              _allCardsView
                  ? Icons.view_headline_outlined
                  : Icons.view_agenda_outlined,
              size: 24,
              color: context.appColors.bookmarksDensityIconColor,
            ),
            tooltip: _allCardsView ? "Contract" : "Expand",
            onPressed: () {
              setState(() {
                _allCardsView = !_allCardsView;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.query_stats,
              size: 26,
              color: context.appColors.bookmarksStatsIconColor,
            ),
            tooltip: "Bookmarks Statistics",
            onPressed: () {
              Navigator.pushNamed(context, RoutesName.bookmarkStatsScreen);
            },
          ),
        ] else ...[
          IconButton(
            icon: Icon(
              Icons.backspace_outlined,
              color: context.appColors.searchBookmarksClearIconColor,
            ),
            tooltip: "Clear Search",
            onPressed: () {
              _searchController.clear();
              _reloadBookmarks();
            },
          ),
        ],
      ],
    );
  }

  // ==================== LEFT SIDEBAR: CATEGORIES & TAGS ====================

  Widget _buildSidebar(
    BuildContext context, {
    required bool isMobileDrawer,
  }) {
    final statsState = context.watch<BookmarksStatsBloc>().state;
    final InternalBookmarksStats? stats = statsState.whenOrNull(
      loaded: (bookmarksStats) => bookmarksStats,
    );

    int? getCategoryCount(int id) {
      if (stats == null) return null;
      for (final cs in stats.categoriesStats) {
        if (cs.category.id == id) return cs.categoryTotalCount;
      }
      return null;
    }

    int? getTagCount(int id) {
      if (stats == null) return null;
      for (final ts in stats.tagsStats) {
        if (ts.tag.id == id) return ts.tagTotalCount;
      }
      return null;
    }

    final totalCount = stats?.globalStats.totalTorrentsCount;

    return Container(
      color: context.appColors.bookmarksSidebarBackgroundColor,
      // Wrap in ScrollConfiguration with scrollbars: false so no duplicate scrollbar appears
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView(
          controller: _sidebarScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          children: [
            if (isMobileDrawer) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Library & Filters",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            context.appColors.bookmarksSidebarHeaderTextColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      color: context.appColors.bookmarksSidebarTileTextColor,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 12,
                color: context.appColors.bookmarksSidebarDividerColor,
              ),
            ],

            // Master tile: "All Bookmarks"
            _buildMasterTile(
              context: context,
              title: "All Bookmarks",
              icon: Icons.bookmarks_rounded,
              count: totalCount,
              isSelected:
                  selectedCategoryId == _allCategoriesId &&
                  selectedTagId == _allTagsId,
              onTap: () {
                setState(() {
                  selectedCategoryId = _allCategoriesId;
                  selectedTagId = _allTagsId;
                });
                _reloadBookmarks();
                if (isMobileDrawer) {
                  Navigator.pop(context);
                }
              },
            ),

            const SizedBox(height: 16),

            // Categories Section Header
            _buildSectionHeader(
              context: context,
              title: "CATEGORIES",
              onAddPressed: () => createItemDialog(
                context,
                title: "New Category",
                hintText: "Category Name",
                emptyErrorMessage: "Category Name can't be empty...",
                onCreate: (name) => context.read<CategoryBloc>().add(
                  CategoryEvent.create(newCategoryName: name),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Categories list
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: CircularProgressBarWidget()),
                  ),
                  loaded: (categoriesList) {
                    if (categoriesList.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 8.0,
                        ),
                        child: Text(
                          "No categories yet",
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.cardSecondaryTextColor,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: categoriesList.map((category) {
                        final isSelected = selectedCategoryId == category.id;
                        final count = getCategoryCount(category.id);
                        return _buildItemRow(
                          context: context,
                          id: category.id,
                          name: category.name,
                          icon: isSelected
                              ? Icons.folder
                              : Icons.folder_outlined,
                          isSelected: isSelected,
                          count: count,
                          onTap: () {
                            setState(() {
                              if (selectedCategoryId == category.id) {
                                selectedCategoryId = _allCategoriesId;
                              } else {
                                selectedCategoryId = category.id;
                              }
                            });
                            _reloadBookmarks();
                            if (isMobileDrawer) {
                              Navigator.pop(context);
                            }
                          },
                          onRename: () => renameItemDialog(
                            context,
                            title: "Rename Category",
                            currentName: category.name,
                            emptyErrorMessage:
                                "Category name can't be empty...",
                            sameNameErrorMessage:
                                "Old and New category name is same...",
                            onRename: (newName) =>
                                context.read<CategoryBloc>().add(
                                  CategoryEvent.rename(
                                    categoryId: category.id,
                                    oldCategoryName: category.name,
                                    newCategoryName: newName,
                                  ),
                                ),
                          ),
                          onDelete: () => deleteItemVerificationDialog(
                            context,
                            title: "Delete Category",
                            description:
                                "This will delete the category and all torrents inside it!",
                            onDelete: () => context.read<CategoryBloc>().add(
                              CategoryEvent.delete(categoryID: category.id),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Tags Section Header
            _buildSectionHeader(
              context: context,
              title: "TAGS",
              onAddPressed: () => createItemDialog(
                context,
                title: "New Tag",
                hintText: "Tag Name",
                emptyErrorMessage: "Tag Name can't be empty...",
                onCreate: (name) => context.read<TagsBloc>().add(
                  TagsEvent.create(newTagName: name),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Tags list
            BlocBuilder<TagsBloc, TagsState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: CircularProgressBarWidget()),
                  ),
                  loaded: (tagsList) {
                    if (tagsList.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 8.0,
                        ),
                        child: Text(
                          "No tags yet",
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.cardSecondaryTextColor,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: tagsList.map((tag) {
                        final isSelected = selectedTagId == tag.id;
                        final count = getTagCount(tag.id);
                        return _buildItemRow(
                          context: context,
                          id: tag.id,
                          name: tag.name,
                          icon: isSelected ? Icons.label : Icons.label_outline,
                          isSelected: isSelected,
                          count: count,
                          onTap: () {
                            setState(() {
                              if (selectedTagId == tag.id) {
                                selectedTagId = _allTagsId;
                              } else {
                                selectedTagId = tag.id;
                              }
                            });
                            _reloadBookmarks();
                            if (isMobileDrawer) {
                              Navigator.pop(context);
                            }
                          },
                          onRename: () => renameItemDialog(
                            context,
                            title: "Rename Tag",
                            currentName: tag.name,
                            emptyErrorMessage: "Tag name can't be empty...",
                            sameNameErrorMessage:
                                "Old and New tag name is same...",
                            onRename: (newName) => context.read<TagsBloc>().add(
                              TagsEvent.rename(
                                tagId: tag.id,
                                oldTagName: tag.name,
                                newTagName: newName,
                              ),
                            ),
                          ),
                          onDelete: () => deleteItemVerificationDialog(
                            context,
                            title: "Delete Tag",
                            description:
                                "This will delete the tag and remove it from all torrents.",
                            onDelete: () => context.read<TagsBloc>().add(
                              TagsEvent.delete(tagID: tag.id),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required VoidCallback onAddPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: context.appColors.bookmarksSidebarHeaderTextColor,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: "Add $title",
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            color: context.appColors.bookmarksSidebarHeaderTextColor,
            onPressed: onAddPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildMasterTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int? count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.bookmarksSidebarSelectedTileBackgroundColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: colors.bookmarksSidebarSelectedTileBorderColor,
                  width: 1.2,
                )
              : Border.all(color: Colors.transparent, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? colors.bookmarksSidebarSelectedTileTextColor
                  : colors.cardSecondaryTextColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? colors.bookmarksSidebarSelectedTileTextColor
                      : colors.bookmarksSidebarTileTextColor,
                ),
              ),
            ),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.bookmarksSidebarSelectedTileBorderColor
                            .withValues(alpha: 0.18)
                      : colors.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(
                          color: colors.bookmarksSidebarSelectedTileBorderColor
                              .withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? colors.bookmarksSidebarSelectedTileTextColor
                        : colors.cardSecondaryTextColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow({
    required BuildContext context,
    required int id,
    required String name,
    required IconData icon,
    required bool isSelected,
    required int? count,
    required VoidCallback onTap,
    required VoidCallback onRename,
    required VoidCallback onDelete,
  }) {
    final colors = context.appColors;
    final bool canModify = id != 0 && id != _allCategoriesId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.bookmarksSidebarSelectedTileBackgroundColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: colors.bookmarksSidebarSelectedTileBorderColor,
                    width: 1.2,
                  )
                : Border.all(color: Colors.transparent, width: 1.2),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? colors.bookmarksSidebarSelectedTileTextColor
                    : colors.bookmarkCategoryIconColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? colors.bookmarksSidebarSelectedTileTextColor
                        : colors.bookmarksSidebarTileTextColor,
                  ),
                ),
              ),
              if (count != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.bookmarksSidebarSelectedTileBorderColor
                              .withValues(alpha: 0.18)
                        : colors.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(
                            color: colors
                                .bookmarksSidebarSelectedTileBorderColor
                                .withValues(alpha: 0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colors.bookmarksSidebarSelectedTileTextColor
                          : colors.cardSecondaryTextColor,
                    ),
                  ),
                ),
              ],
              if (canModify)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  tooltip: "Options",
                  color: colors.bookmarkCategoryOptionPopupMenuBackgroundColor,
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: colors.bookmarkCategoryOptionPopupMenuIconColor,
                  ),
                  onSelected: (val) {
                    if (val == 'rename') {
                      onRename();
                    } else if (val == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'rename', child: Text('Rename')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== RIGHT PANE: ACTIVE FILTERS & TORRENTS ====================

  Widget _buildTorrentsPane(BuildContext context) {
    return Column(
      children: [
        _buildActiveFilterBar(context),
        Expanded(
          child: BlocBuilder<BookmarkBloc, BookmarkState>(
            builder: (context, state) {
              return state.when(
                initial: () => const Center(child: Text("Initial State")),
                loading: () => const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressBarWidget()),
                ),
                loaded: (torrents, _, _, hasMore) {
                  if (torrents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Icon(
                            Icons.bookmark_border_rounded,
                            size: 48,
                            color: context.appColors.cardSecondaryTextColor
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isSearching
                                ? "No Result Found..."
                                : "No bookmarks in this selection.",
                            style: TextStyle(
                              color: context.appColors.generalTextColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Single clean scrollbar for the right pane
                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: Scrollbar(
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(
                          top: 6,
                          left:
                              Platform.isLinux ||
                                  Platform.isWindows ||
                                  Platform.isMacOS
                              ? 12
                              : 6,
                          right:
                              Platform.isLinux ||
                                  Platform.isWindows ||
                                  Platform.isMacOS
                              ? 12
                              : 6,
                          bottom: 80,
                        ),
                        itemCount: torrents.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= torrents.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressBarWidget()),
                            );
                          }
                          final torrent = torrents[index];
                          return ExpandableTorrentCard(
                            key: ValueKey(torrent.infoHash),
                            torrent: torrent,
                            forceExpanded: _allCardsView,
                          );
                        },
                      ),
                    ),
                  );
                },
                error: (e) => Center(child: Text("Error : ${e.toString()}")),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilterBar(BuildContext context) {
    final bool isCategoryFiltered =
        selectedCategoryId != null && selectedCategoryId != _allCategoriesId;
    final bool isTagFiltered =
        selectedTagId != null && selectedTagId != _allTagsId;

    if (!isCategoryFiltered && !isTagFiltered) {
      return const SizedBox.shrink();
    }

    final categoryState = context.watch<CategoryBloc>().state;
    String categoryName = "Category";
    categoryState.whenOrNull(
      loaded: (list) {
        final match = list.where((c) => c.id == selectedCategoryId);
        if (match.isNotEmpty) categoryName = match.first.name;
      },
    );

    final tagsState = context.watch<TagsBloc>().state;
    String tagName = "Tag";
    tagsState.whenOrNull(
      loaded: (list) {
        final match = list.where((t) => t.id == selectedTagId);
        if (match.isNotEmpty) tagName = match.first.name;
      },
    );

    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.cardColor.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: colors.cardSecondaryTextColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: colors.cardSecondaryTextColor,
          ),
          const SizedBox(width: 8),
          Text(
            "Filter:",
            style: TextStyle(
              fontSize: 12,
              color: colors.cardSecondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          if (isCategoryFiltered)
            _buildFilterChip(
              context: context,
              label: categoryName,
              icon: Icons.folder,
              onClear: () {
                setState(() => selectedCategoryId = _allCategoriesId);
                _reloadBookmarks();
              },
            ),
          if (isCategoryFiltered && isTagFiltered) const SizedBox(width: 8),
          if (isTagFiltered)
            _buildFilterChip(
              context: context,
              label: tagName,
              icon: Icons.label,
              onClear: () {
                setState(() => selectedTagId = _allTagsId);
                _reloadBookmarks();
              },
            ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                selectedCategoryId = _allCategoriesId;
                selectedTagId = _allTagsId;
              });
              _reloadBookmarks();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Clear all",
              style: TextStyle(
                fontSize: 12,
                color: colors.cardSecondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onClear,
  }) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.cardSecondaryTextColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.cardSecondaryTextColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.generalTextColor,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(10),
            child: Icon(
              Icons.close,
              size: 14,
              color: colors.cardSecondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
