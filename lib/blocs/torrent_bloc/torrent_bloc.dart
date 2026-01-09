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
        final torrentsListAndPagination = await searchTorrent(
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
            torrents: torrentsListAndPagination.$1,
            torrentName: event.torrentName,
          ),
        );

        // emitting pagination state
        final pagination = torrentsListAndPagination.$2;
        paginationBloc.add(
          PaginationEvent.initPagination(pagination: pagination),
        );
        
      } catch (e) {
        emit(TorrentSearchFailure(error: e.toString()));
      }
    });
  }
}
