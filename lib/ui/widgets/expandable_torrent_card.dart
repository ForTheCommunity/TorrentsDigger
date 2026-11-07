import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/torrent_card.dart';

class ExpandableTorrentCard extends StatefulWidget {
  final InternalTorrent torrent;
  final bool forceExpanded;

  const ExpandableTorrentCard({
    super.key,
    required this.torrent,
    this.forceExpanded = false,
  });

  @override
  State<ExpandableTorrentCard> createState() => _ExpandableTorrentCardState();
}

class _ExpandableTorrentCardState extends State<ExpandableTorrentCard> {
  bool _isManuallyExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isExpanded = widget.forceExpanded || _isManuallyExpanded;
    final colors = context.appColors;

    if (isExpanded) {
      final cardWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TorrentCard(torrent: widget.torrent),
      );

      if (widget.forceExpanded) {
        return cardWidget;
      }

      // Tap on card area collapses back to row
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _isManuallyExpanded = false;
          });
        },
        child: cardWidget,
      );
    }

    // Clean, minimal Compact Row View: clicks expand into full card
    return Card(
      color: colors.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: colors.cardSecondaryTextColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _isManuallyExpanded = true),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: colors.cardSecondaryTextColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.torrent.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.cardPrimaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          widget.torrent.size,
                          style: TextStyle(
                            color: colors.cardSecondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          " • ",
                          style: TextStyle(
                            color: colors.cardSecondaryTextColor.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                        const Icon(Icons.arrow_upward, size: 12, color: Colors.green),
                        const SizedBox(width: 2),
                        Text(
                          widget.torrent.seeders,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_downward, size: 12, color: Colors.red),
                        const SizedBox(width: 2),
                        Text(
                          widget.torrent.leechers,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.torrent.date.isNotEmpty) ...[
                          Text(
                            " • ",
                            style: TextStyle(
                              color: colors.cardSecondaryTextColor.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: colors.cardSecondaryTextColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.torrent.date,
                            style: TextStyle(
                              color: colors.cardSecondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.unfold_more,
                size: 18,
                color: colors.cardSecondaryTextColor.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
