import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/expandable_torrent_card.dart';

class TorrentListWidget extends StatefulWidget {
  final List<InternalTorrent> torrents;
  final bool showDensityToggle;

  const TorrentListWidget({
    super.key,
    required this.torrents,
    this.showDensityToggle = true,
  });

  @override
  State<TorrentListWidget> createState() => _TorrentListWidgetState();
}

class _TorrentListWidgetState extends State<TorrentListWidget> {
  bool _allCardsView = false; // false = compact rows (expand on click), true = full cards

  @override
  Widget build(BuildContext context) {
    if (widget.torrents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showDensityToggle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${widget.torrents.length} ${widget.torrents.length == 1 ? 'Torrent' : 'Torrents'}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.cardSecondaryTextColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _allCardsView
                        ? Icons.view_headline_outlined
                        : Icons.view_agenda_outlined,
                    size: 22,
                    color: context.appColors.bookmarksDensityIconColor,
                  ),
                  tooltip: _allCardsView
                      ? "Contract"
                      : "Expand",
                  onPressed: () {
                    setState(() {
                      _allCardsView = !_allCardsView;
                    });
                  },
                ),
              ],
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.torrents.length,
          itemBuilder: (context, index) {
            final torrent = widget.torrents[index];
            return ExpandableTorrentCard(
              key: ValueKey(torrent.infoHash),
              torrent: torrent,
              forceExpanded: _allCardsView,
            );
          },
        ),
      ],
    );
  }
}
