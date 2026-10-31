part of 'torrent_bloc.dart';

@immutable
sealed class TorrentState {}

class TorrentInitial extends TorrentState {}

class TorrentSearchLoading extends TorrentState {}

class TorrentSearchSuccess extends TorrentState {
  final List<InternalTorrent> torrents;
  final String torrentName;
  TorrentSearchSuccess({required this.torrents, required this.torrentName});
}

class TorrentSearchFailure extends TorrentState {
  final String error;
  TorrentSearchFailure({required this.error});
}

class TorrentCloudflareChallengeState extends TorrentState {
  final String challengeUrl;
  final SearchTorrents retryEvent;
  final bool autoPrompt;

  TorrentCloudflareChallengeState({
    required this.challengeUrl,
    required this.retryEvent,
    this.autoPrompt = true,
  });
}
