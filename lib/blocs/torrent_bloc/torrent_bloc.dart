import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:torrents_digger/dig_torrent/search_torrent.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

part 'torrent_event.dart';
part 'torrent_state.dart';

class TorrentBloc extends Bloc<TorrentEvents, TorrentState> {
  TorrentBloc() : super(TorrentInitial()) {
    on<SearchTorrents>((event, emit) async {
      emit(TorrentSearchLoading());
      try {
        final torrents = await searchTorrent(
          torrentName: event.torrentName,
          source: event.source,
          filter: event.filter,
          category: event.category,
          sorting: event.sorting,
        );
        emit(TorrentSearchSuccess(torrents: torrents));
      } catch (e) {
        emit(TorrentSearchFailure(error: e.toString()));
      }
    });
  }
}
