import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/pagination_bloc/pagination_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/blocs/torrent_bloc/torrent_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/configs/nsfw_helper.dart';
import 'package:torrents_digger/database/get_settings_data.dart';
import 'package:torrents_digger/services/version_service.dart';
import 'package:torrents_digger/ui/widgets/dropdowns_ui.dart';
import 'package:torrents_digger/ui/widgets/floating_action_buttons.dart';
import 'package:torrents_digger/ui/widgets/launch_url.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:torrents_digger/ui/widgets/search_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/torrents_list_ui.dart';
import 'package:torrents_digger/ui/widgets/update_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static bool _hasCheckedUpdateOnStartup = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdateOnStartup();
    });
  }

  Future<void> _checkUpdateOnStartup() async {
    if (_hasCheckedUpdateOnStartup) return;
    _hasCheckedUpdateOnStartup = true;

    try {
      final autoCheck = await getAutoCheckUpdates();
      if (!autoCheck) return;

      // Allow initial UI render to settle smoothly
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      final updateCode = await checkNewUpdate();
      if (updateCode == 0 && mounted) {
        String? currentVer;
        try {
          currentVer = await getAppCurrentVersion();
        } catch (_) {}

        if (mounted) {
          final targetContext = navigatorKey.currentContext ?? context;
          showUpdateDialog(targetContext, currentVersion: currentVer);
        }
      }
    } catch (_) {
      // Silently ignore network or offline errors during startup check
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final torrentState = context.watch<TorrentBloc>().state;
    final bool hasTorrents =
        torrentState is TorrentSearchSuccess && torrentState.torrents.isNotEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionsButtons(
        scrollToTop: true,
        enableAddTorrent: false,
        enableBookmarks: true,
        enableCustoms: true,
        enableSettings: true,
        activeScreen: ActiveScreen.search,
        scrollController: _scrollController,
        hasTorrents: hasTorrents,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      backgroundColor: context.appColors.scaffoldColor,
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal:
                    Platform.isLinux || Platform.isWindows || Platform.isMacOS
                    ? 15
                    : Platform.isAndroid || Platform.isIOS
                    ? 7.0
                    : 7.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // SearchBar Widget
                  SearchBarWidget(
                    searchController: _searchController,
                    onSearchPressed: () {
                      String torrentName = _searchController.text.trim();
                      final sourceState = context.read<SourceBloc>().state;

                      // resetting pagination
                      context.read<PaginationBloc>().add(
                        PaginationEvent.resetPagination(),
                      );

                      if (torrentName.isNotEmpty) {
                        if (sourceState.selectedSource != null) {
                          if (!sourceState
                              .isSourceEnabled(sourceState.selectedSource!)) {
                            createSnackBar(
                              message:
                                  "Selected source is disabled in settings.",
                              duration: 2,
                            );
                            return;
                          }

                          if (sourceState.hideNsfw &&
                              sourceState.selectedCategory != null &&
                              NsfwHelper.isNsfwCategory(
                                sourceState.selectedCategory!,
                              )) {
                            createSnackBar(
                              message:
                                  "Selected category is hidden by NSFW filter.",
                              duration: 2,
                            );
                            return;
                          }

                          final details = sourceState.selectedDetails!;
                          final bool categoriesOk =
                              !details.queryOptions.categories ||
                              (details.queryOptions.categories &&
                                  sourceState.selectedCategory != null);
                          final bool filtersOk =
                              !details.queryOptions.filters ||
                              (details.queryOptions.filters &&
                                  sourceState.selectedFilter != null);
                          final bool sortingsOk =
                              !details.queryOptions.sortings ||
                              (details.queryOptions.sortings &&
                                  sourceState.selectedSorting != null);
                          final bool sortingsOrderOk =
                              !details.queryOptions.sortingOrders ||
                              (details.queryOptions.sortingOrders &&
                                  sourceState.selectedSortingOrder != null);

                          if (!categoriesOk ||
                              !filtersOk ||
                              !sortingsOk ||
                              !sortingsOrderOk) {
                            createSnackBar(
                              message: "Use Available Options... :)",
                              duration: 2,
                            );
                            return;
                          }

                          // Source
                          List<String> listOfSources = sourceState.sources
                              .map((source) => source.sourceName)
                              .toList();
                          int sourceIndex = listOfSources.indexOf(
                            sourceState.selectedSource!,
                          );

                          // Source Categories
                          List<String> listOfCategories = sourceState.sources
                              .firstWhere(
                                (source) =>
                                    source.sourceName ==
                                    sourceState.selectedSource!,
                              )
                              .sourceDetails
                              .categories;

                          int categoryIndex =
                              (listOfCategories.isNotEmpty &&
                                  sourceState.selectedCategory != null)
                              ? listOfCategories.indexOf(
                                  sourceState.selectedCategory!,
                                )
                              : -1;

                          // Source Filters
                          List<String> listOfFilters = sourceState.sources
                              .firstWhere(
                                (source) =>
                                    source.sourceName ==
                                    sourceState.selectedSource!,
                              )
                              .sourceDetails
                              .sourceFilters;

                          int filterIndex =
                              (listOfFilters.isNotEmpty &&
                                  sourceState.selectedFilter != null)
                              ? listOfFilters.indexOf(
                                  sourceState.selectedFilter!,
                                )
                              : -1;

                          // Source Sortings
                          List<String> listOfSortings = sourceState.sources
                              .firstWhere(
                                (source) =>
                                    source.sourceName ==
                                    sourceState.selectedSource!,
                              )
                              .sourceDetails
                              .sourceSortings;

                          int sortingIndex =
                              (listOfSortings.isNotEmpty &&
                                  sourceState.selectedSorting != null)
                              ? listOfSortings.indexOf(
                                  sourceState.selectedSorting!,
                                )
                              : -1;

                          // Source Sorting Order
                          List<String> listOfSortingOrders = sourceState.sources
                              .firstWhere(
                                (source) =>
                                    source.sourceName ==
                                    sourceState.selectedSource!,
                              )
                              .sourceDetails
                              .sourceSortingOrders;

                          int sortingOrderIndex =
                              (listOfSortingOrders.isNotEmpty &&
                                  sourceState.selectedSortingOrder != null)
                              ? listOfSortingOrders.indexOf(
                                  sourceState.selectedSortingOrder!,
                                )
                              : -1;

                          context.read<TorrentBloc>().add(
                            SearchTorrents(
                              torrentName: torrentName,
                              sourceIndex: sourceIndex,
                              categoryIndex: categoryIndex,
                              filterIndex: filterIndex,
                              sortingIndex: sortingIndex,
                              sortingOrderIndex: sortingOrderIndex,
                            ),
                          );
                        } else {
                          createSnackBar(
                            message: "Use Available Options... :)",
                            duration: 2,
                          );
                        }
                      } else {
                        createSnackBar(
                          message: "Enter Torrent Name To Search... :)",
                          duration: 2,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  // Dropdowns Ui
                  DropdownsUi(),

                  const SizedBox(height: 24),
                  const TorrentsListUi(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
