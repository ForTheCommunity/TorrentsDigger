import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/category_bloc/category_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/tags_bloc/tags_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/routes/routes_name.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/chip_grid_widgets.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/floating_action_buttons.dart';
import 'package:torrents_digger/ui/widgets/torrent_list_widget.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarksScreen> {
  static const int _allCategoriesId = 65535;
  static const int _allTagsId = 65535;
  int? selectedCategoryId = 65535;
  int? selectedTagId = 65535;
  final ScrollController _scrollController = ScrollController();

  // search state
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Dispatching the load event immediately when the screen initializes
    context.read<CategoryBloc>().add(const CategoryEvent.load());
    context.read<TagsBloc>().add(const TagsEvent.load());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Fire when within 200px of the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BookmarkBloc>().add(const BookmarkEvent.loadMoreBookmarks());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.arrow_back,
            color: context.appColors.appBarBackButtonIconColor,
          ),
          iconSize: 30,
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
              // Reset search results by reloading bookmarks normally
              context.read<BookmarkBloc>().add(
                BookmarkEvent.loadBookmarks(
                  categoryID: selectedCategoryId ?? 0,
                  tagID: selectedTagId ?? 0,
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Colors.amber, fontSize: 18),
                decoration: InputDecoration(
                  hint: Text(
                    'Search Bookmarks...',
                    style: TextStyle(
                      fontSize: 20,
                      color:
                          context.appColors.searchBookmarksPlaceholderTextColor,
                    ),
                  ),

                  border: InputBorder.none,
                ),
                onChanged: (searchQueryText) {
                  String searchQuery = searchQueryText.trim();
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 350), () {
                    if (searchQuery.isEmpty) {
                      // go back to normal paginated view
                      //
                      context.read<BookmarkBloc>().add(
                        BookmarkEvent.loadBookmarks(
                          categoryID: selectedCategoryId ?? 0,
                        ),
                      );
                      //
                    } else {
                      context.read<BookmarkBloc>().add(
                        BookmarkEvent.searchBookmarkedTorrents(
                          text: searchQuery,
                        ),
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
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),

        actions: [
          if (!_isSearching) ...[
            IconButton(
              icon: Icon(
                Icons.search,
                size: 28,
                color: context.appColors.searchBookmarksIconColor,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),

            IconButton(
              icon: Icon(
                Icons.query_stats,
                size: 28,
                color: context.appColors.bookmarksStatsIconColor,
              ),
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
              onPressed: () {
                _searchController.clear();
              },
            ),
          ],
        ],
      ),

      floatingActionButton: FloatingActionsButtons(
        scrollToTop: true,
        enableBookmarks: false,
        enableCustoms: true,
        enableSettings: true,
        scrollController: _scrollController,
      ),

      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            primary: false,
            controller: _scrollController,

            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal:
                    Platform.isLinux || Platform.isWindows || Platform.isMacOS
                    ? 15
                    : (Platform.isAndroid || Platform.isIOS ? 7.0 : 7.0),
              ),

              child: Column(
                children: [
                  // Category Section
                  BlocConsumer<CategoryBloc, CategoryState>(
                    listener: (context, state) {
                      state.whenOrNull(
                        loaded: (_) {
                          context.read<BookmarkBloc>().add(
                            BookmarkEvent.loadBookmarks(
                              categoryID:
                                  selectedCategoryId ?? _allCategoriesId,
                              tagID: selectedTagId ?? _allTagsId,
                            ),
                          );
                        },
                      );
                    },
                    builder: (context, state) {
                      return state.when(
                        initial: () => const SizedBox.shrink(),
                        loading: () => const CircularProgressBarWidget(),
                        loaded: (categoriesList) =>
                            _buildCategoryGrid(context, categoriesList),
                      );
                    },
                  ),

                  const Divider(height: 1, thickness: 1),

                  // Tags Section..
                  BlocBuilder<TagsBloc, TagsState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () =>
                            const
                            // SizedBox.shrink()
                            Text("data"),
                        loading: () => const CircularProgressBarWidget(),
                        loaded: (tagsList) => _buildTagGrid(context, tagsList),
                      );
                    },
                  ),

                  const Divider(height: 1, thickness: 1),

                  // Bookmarked Torrents UI Section.
                  BlocBuilder<BookmarkBloc, BookmarkState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () => const Text("Initial State"),
                        loading: () => const SizedBox(
                          height: 400,
                          child: Center(child: CircularProgressBarWidget()),
                        ),
                        loaded: (torrents, _, _, hasMore) {
                          if (torrents.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10),
                                  Text(
                                    _isSearching
                                        ? "No Result Found..."
                                        : "This Category has 0 Torrents.",
                                    style: TextStyle(
                                      color: context.appColors.generalTextColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              TorrentListWidget(torrents: torrents),
                              if (hasMore)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressBarWidget(),
                                  ),
                                ),
                            ],
                          );
                        },

                        error: (e) =>
                            Center(child: Text("Error : ${e.toString()}")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagGrid(
    BuildContext context,
    List<InternalBookmarkTag> tagList,
  ) {
    return buildChipGrid(
      context: context,
      items: tagList.map((t) => (t.id, t.name)).toList(),
      selectedID: selectedTagId,
      onTap: (id) {
        setState(() => selectedTagId = id);
        context.read<BookmarkBloc>().add(
          BookmarkEvent.loadBookmarks(
            categoryID: selectedCategoryId ?? 0,
            tagID: id,
          ),
        );
      },
      newButtonLabel: "New Tag +",
      oneNewTap: () => createItemDialog(
        context,
        title: "New Tag",
        hintText: "Tag Name",
        emptyErrorMessage: "Tag Name can't be empty...",
        onCreate: (name) => {
          context.read<TagsBloc>().add(TagsEvent.create(newTagName: name)),
        },
      ),
      menuBuilder: (id) {
        final tag = tagList.firstWhere((t) => t.id == id);
        return [
          PopupMenuItem(
            value: 'rename',
            onTap: () => renameItemDialog(
              context,
              title: "Rename Tag",
              currentName: tag.name,
              emptyErrorMessage: "Tag name can't be empty...",
              sameNameErrorMessage: "Old and New tag name is same...",
              onRename: (newName) => context.read<TagsBloc>().add(
                TagsEvent.rename(
                  tagId: tag.id,
                  oldTagName: tag.name,
                  newTagName: newName,
                ),
              ),
            ),
            child: const Text('Rename'),
          ),
          PopupMenuItem(
            value: 'delete',
            onTap: () => deleteItemVerificationDialog(
              context,
              title: "Delete Tag",
              description:
                  "This will delete the tag and remove it from all torrents...",
              onDelete: () =>
                  context.read<TagsBloc>().add(TagsEvent.delete(tagID: tag.id)),
            ),
            child: const Text('Delete'),
          ),
        ];
      },
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    List<InternalBookmarkCategory> categoriesList,
  ) {
    return buildChipGrid(
      context: context,
      items: categoriesList.map((cl) => (cl.id, cl.name)).toList(),
      selectedID: selectedCategoryId,
      onTap: (id) {
        setState(() {
          selectedCategoryId = id;
          selectedTagId = selectedTagId ?? 0;
        });
        context.read<BookmarkBloc>().add(
          BookmarkEvent.loadBookmarks(
            categoryID: id,
            tagID: selectedTagId ?? 0,
          ),
        );
      },
      newButtonLabel: "New Category +",
      oneNewTap: () => createItemDialog(
        context,
        title: "New Category",
        hintText: "Category Name",
        emptyErrorMessage: "Category Name can't be empty...",
        onCreate: (name) => {
          context.read<CategoryBloc>().add(
            CategoryEvent.create(newCategoryName: name),
          ),
        },
      ),
      menuBuilder: (id) {
        final category = categoriesList.firstWhere((c) => c.id == id);
        return [
          PopupMenuItem(
            value: 'rename',
            child: const Text('Rename'),
            onTap: () => renameItemDialog(
              context,
              title: "Rename Category",
              currentName: category.name,
              emptyErrorMessage: "Category name can't be empty...",
              sameNameErrorMessage: "Old and New category name is same...",
              onRename: (newName) => context.read<CategoryBloc>().add(
                CategoryEvent.rename(
                  categoryId: category.id,
                  oldCategoryName: category.name,
                  newCategoryName: newName,
                ),
              ),
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: const Text('Delete'),
            onTap: () => deleteItemVerificationDialog(
              context,
              title: "Delete Category",
              description:
                  "This will delete the category and all torrents inside it !!!",
              onDelete: () => context.read<CategoryBloc>().add(
                CategoryEvent.delete(categoryID: category.id),
              ),
            ),
          ),
        ];
      },
    );
  }
}
