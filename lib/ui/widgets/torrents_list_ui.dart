import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/torrent_bloc/torrent_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/ui/widgets/cf_solver_dialog.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/pagination_widget.dart';
import 'package:torrents_digger/ui/widgets/torrent_list_widget.dart';

class TorrentsListUi extends StatelessWidget {
  const TorrentsListUi({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TorrentBloc, TorrentState>(
      listener: (context, state) {
        if (state is TorrentCloudflareChallengeState) {

          final torrentBloc = context.read<TorrentBloc>();
          CloudflareSolverDialog.show(context, state.challengeUrl).then((solved) {
        
            if (!context.mounted) return;
            if (solved == true) {
          
               //  Retrying search event after challenge solved...
              torrentBloc.add(state.retryEvent);
            } else {
               // Solver closed without solving (solved != true)
            }
          });
        }
      },
      builder: (context, state) {
        switch (state) {
          case TorrentInitial():
            return Center(
              child: Text(
                "Search Torrent , Get Torrents...",
                style: TextStyle(
                  color: context.appColors.generalTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          case TorrentSearchLoading():
            return const Center(child: CircularProgressBarWidget());
          case TorrentSearchSuccess():
            return state.torrents.isEmpty
                ? Center(
                    child: Text(
                      "No Torrent Found...",
                      style: TextStyle(
                        color: context.appColors.generalTextColor,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      TorrentListWidget(torrents: state.torrents),
                      PaginationWidget(),
                    ],
                  );
          case TorrentCloudflareChallengeState():
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security_outlined,
                    size: 48,
                    color: context.appColors.circularProgressIndicatorColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Cloudflare verification required",
                    style: TextStyle(
                      color: context.appColors.generalTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          context.appColors.circularProgressIndicatorColor,
                      foregroundColor: context.appColors.scaffoldColor,
                    ),
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text("Solve Verification Challenge"),
                    onPressed: () {
                      final torrentBloc = context.read<TorrentBloc>();
                      CloudflareSolverDialog.show(context, state.challengeUrl)
                          .then((solved) {
                        if (!context.mounted) return;
                        if (solved == true) {
                          torrentBloc.add(state.retryEvent);
                        }
                      });
                    },
                  ),
                ],
              ),
            );
          case TorrentSearchFailure():
            return Center(
              child: Text(
                "Failed to fetch Torrents \n Error : ${state.error}",
                style: TextStyle(
                  color: context.appColors.generalTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            );
        }
      },
    );
  }
}
