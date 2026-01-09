import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/pagination_bloc/pagination_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/blocs/torrent_bloc/torrent_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/ui/widgets/dropdowns_ui.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:torrents_digger/ui/widgets/search_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/settings_button.dart';
import 'package:torrents_digger/ui/widgets/torrents_list_ui.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    return Scaffold(
      floatingActionButton: SettingButton(),
      backgroundColor: context.appColors.scaffoldColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: Platform.isLinux
                  ? 15
                  : (Platform.isAndroid ? 7.0 : 7.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // SearchBar Widget
                SearchBarWidget(
                  searchController: searchController,
                  onSearchPressed: () {
                    String torrentName = searchController.text.trim();
                    final sourceState = context.read<SourceBloc>().state;

                    // resetting pagination
                    context.read<PaginationBloc>().add(
                      PaginationEvent.resetPagination(),
                    );

                    if (torrentName.isNotEmpty) {
                      if (sourceState.selectedSource != null) {
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
                            ? listOfFilters.indexOf(sourceState.selectedFilter!)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
