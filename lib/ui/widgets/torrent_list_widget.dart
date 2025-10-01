import 'package:flutter/material.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/torrent_card.dart';

class TorrentListWidget extends StatelessWidget {
  final List<InternalTorrent> torrents;

  const TorrentListWidget({super.key, required this.torrents});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: torrents.length,
      itemBuilder: (context, index) {
        final torrent = torrents[index];
        return TorrentCard(torrent: torrent);
      },
    );
  }
}
