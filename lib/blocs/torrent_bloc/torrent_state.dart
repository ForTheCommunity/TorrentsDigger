part of 'torrent_bloc.dart';

@immutable
sealed class TorrentState {}

class TorrentInitial extends TorrentState {}

class TorrentSearchLoading extends TorrentState {}

class TorrentSearchSuccess extends TorrentState {
  final List<InternalTorrent> torrents;
  TorrentSearchSuccess({required this.torrents});
}

class TorrentSearchFailure extends TorrentState {
  final String error;
  TorrentSearchFailure({required this.error});
}

