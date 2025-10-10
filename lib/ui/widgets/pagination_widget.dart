import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/pagination_bloc/pagination_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/blocs/torrent_bloc/torrent_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';

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
                        context.read<TorrentBloc>().add(
                          SearchTorrents(
                            torrentName: torrentState.torrentName,
                            source: sourceState.selectedSource!,
                            filter: sourceState.selectedFilter ?? "",
                            category: sourceState.selectedCategory ?? "",
                            sorting: sourceState.selectedSorting ?? "",
                            page: nextPage,
                          ),
                        );
                      }
                    }
                  : null,
              child: Text(
                "Next ->",
                style: TextStyle(color: AppColors.greenColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
