import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/torrent_bloc/torrent_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/pagination_widget.dart';
import 'package:torrents_digger/ui/widgets/torrent_list_widget.dart';

class TorrentsListUi extends StatelessWidget {
  const TorrentsListUi({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TorrentBloc, TorrentState>(
      builder: (context, state) {
        switch (state) {
          case TorrentInitial():
            return Center(
              child: Text(
                "Search Torrent , Get Torrents...",
                style: TextStyle(
                  color: context.appColors.generalTextColor,
                  fontSize: 15,
                ),
              ),
            );
          case TorrentSearchLoading():
            return const Center(child: CircularProgressBarWidget());
          case TorrentSearchSuccess():
            return state.torrents.isEmpty
                ? const Center(child: Text("No Torrent Found..."))
                : Column(
                    children: [
                      TorrentListWidget(torrents: state.torrents),
                      PaginationWidget(),
                    ],
                  );
          case TorrentSearchFailure():
            return Center(
              child: Text("Failed to fetch Torrents \n Error : ${state.error}"),
            );
        }
      },
    );
  }
}
