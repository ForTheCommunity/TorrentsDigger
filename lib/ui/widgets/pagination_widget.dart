import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/pagination_bloc/pagination_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/blocs/torrent_bloc/torrent_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

class PaginationWidget extends StatelessWidget {
  const PaginationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sourceState = context.watch<SourceBloc>().state;

    // if source doesn't have pagination option
    if (!(sourceState.selectedDetails?.queryOptions.pagination ?? false)) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<PaginationBloc, PaginationState>(
      builder: (context, state) {
        return state.maybeWhen(
          initial: () => const SizedBox.shrink(),
          loading: () => const CircularProgressBarWidget(),
          error: (error) {
            createSnackBar(message: "Pagination Error: $error", duration: 5);
            return Text("Pagination Error : $error");
          },
          loaded: (pagination) {
            final currentPage = pagination.currentPage;
            final previousPage = pagination.previousPage;
            final nextPage = pagination.nextPage;

            if (currentPage == null &&
                previousPage == null &&
                nextPage == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (previousPage != null)
                    IconButton(
                      onPressed: () => _onPageChange(context, previousPage),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: context
                            .appColors
                            .paginationPreviousButtonBackgroundColor,
                      ),
                    ),
                  if (currentPage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        "$currentPage",
                        style: TextStyle(
                          color: context.appColors.paginationCurrentTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (nextPage != null)
                    IconButton(
                      onPressed: () => _onPageChange(context, nextPage),
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: context
                            .appColors
                            .paginationNextButtonBackgroundColor,
                      ),
                    ),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  void _onPageChange(BuildContext context, int page) {
    final sourceState = context.read<SourceBloc>().state;
    final torrentState = context.read<TorrentBloc>().state;

    if (torrentState is TorrentSearchSuccess) {
      final String torrentName = torrentState.torrentName;
      final details = sourceState.selectedDetails;

      if (sourceState.selectedSource != null && details != null) {
        context.read<TorrentBloc>().add(
          SearchTorrents(
            torrentName: torrentName,
            sourceIndex: getIndex(
              sourceState.sources.map((e) => e.sourceName).toList(),
              sourceState.selectedSource,
            ),
            categoryIndex: getIndex(
              details.categories,
              sourceState.selectedCategory,
            ),
            filterIndex: getIndex(
              details.sourceFilters,
              sourceState.selectedFilter,
            ),
            sortingIndex: getIndex(
              details.sourceSortings,
              sourceState.selectedSorting,
            ),
            sortingOrderIndex: getIndex(
              details.sourceSortingOrders,
              sourceState.selectedSortingOrder,
            ),
            page: page,
          ),
        );
      }
    } else {
      createSnackBar(message: "Search Not Active...", duration: 2);
    }
  }
}

// Helper function to get index
int getIndex(List<String> list, String? selected) =>
    (list.isNotEmpty && selected != null) ? list.indexOf(selected) : -1;
