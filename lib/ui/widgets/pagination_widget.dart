import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/pagination_bloc/pagination_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/blocs/torrent_bloc/torrent_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
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

    final isTorrentLoading =
        context.watch<TorrentBloc>().state is TorrentSearchLoading;

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

            final hasPrevious = previousPage != null && !isTorrentLoading;
            final hasNext = nextPage != null && !isTorrentLoading;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: hasPrevious
                        ? () => _onPageChange(context, previousPage)
                        : null,
                    splashRadius: 20,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: hasPrevious
                          ? context
                              .appColors
                              .paginationPreviousButtonBackgroundColor
                          : context.appColors.cardSecondaryTextColor
                              .withValues(alpha: 0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: context.appColors.cardSecondaryTextColor,
                        ),
                        children: [
                          const TextSpan(text: "Page "),
                          TextSpan(
                            text: "$currentPage",
                            style: TextStyle(
                              color:
                                  context.appColors.paginationCurrentTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: hasNext
                        ? () => _onPageChange(context, nextPage)
                        : null,
                    splashRadius: 20,
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: hasNext
                          ? context
                              .appColors
                              .paginationNextButtonBackgroundColor
                          : context.appColors.cardSecondaryTextColor
                              .withValues(alpha: 0.2),
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
    final torrentState = context.read<TorrentBloc>().state;
    if (torrentState is TorrentSearchLoading) return;

    final sourceState = context.read<SourceBloc>().state;

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
