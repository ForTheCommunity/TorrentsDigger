import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/pagination_bloc/pagination_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/blocs/torrent_bloc/torrent_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';

class PaginationWidget extends StatelessWidget {
  const PaginationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sourceState = context.read<SourceBloc>().state;
    final torrentState = context.read<TorrentBloc>().state;

    if (!(sourceState.selectedDetails?.queryOptions.pagination ?? false)) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<PaginationBloc, PaginationState>(
      builder: (context, state) {
        final nextPage = state.nextPage;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // previous page and current page widget is
            // disabled for now.
            // ElevatedButton(
            //   onPressed: () {},
            //   child: const Icon(
            //     Icons.keyboard_arrow_left,
            //     color: AppColors.greenColor,
            //     weight: 900,
            //   ),
            // ),
            // const SizedBox(width: 20),
            // Text(currentPage.toString()),
            // const SizedBox(width: 20),
            ElevatedButton(
              onPressed: state.nextPage != null
                  ? () {
                      if (torrentState is TorrentSearchSuccess) {
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
                        int categoryIndex = listOfCategories.indexOf(
                          sourceState.selectedCategory!,
                        );

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
                            torrentName: torrentState.torrentName,
                            sourceIndex: sourceIndex,
                            categoryIndex: categoryIndex,
                            filterIndex: filterIndex,
                            sortingIndex: sortingIndex,
                            sortingOrderIndex: sortingOrderIndex,
                            page: nextPage,
                          ),
                        );
                      }
                    }
                  : null,
              child: Text(
                "Next ->",
                style: TextStyle(color: context.appColors.generalTextColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
