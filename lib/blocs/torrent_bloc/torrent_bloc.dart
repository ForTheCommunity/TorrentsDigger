import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:torrents_digger/blocs/pagination_bloc/pagination_bloc.dart';
import 'package:torrents_digger/dig_torrent/search_torrent.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

part 'torrent_event.dart';
part 'torrent_state.dart';

class TorrentBloc extends Bloc<TorrentEvents, TorrentState> {
  final PaginationBloc paginationBloc;
  TorrentBloc({required this.paginationBloc}) : super(TorrentInitial()) {
    on<SearchTorrents>((event, emit) async {
      emit(TorrentSearchLoading());
      try {
        final torrentsListAndNextPage = await searchTorrent(
          torrentName: event.torrentName,
          sourceIndex: event.sourceIndex,
          categoryIndex: event.categoryIndex,
          filterIndex: event.filterIndex,
          sortingIndex: event.sortingIndex,
          sortingOrderIndex: event.sortingOrderIndex,
          page: event.page,
        );

        emit(
          TorrentSearchSuccess(
            torrents: torrentsListAndNextPage.$1,
            torrentName: event.torrentName,
          ),
        );
        // emitting pagination state
        final nextPage = torrentsListAndNextPage.$2;
        if (nextPage != null) {
          paginationBloc.add(SetNextPage(nextPage));
        }
      } catch (e) {
        emit(TorrentSearchFailure(error: e.toString()));
      }
    });
  }
}
