import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmark_bloc/bookmark_bloc.dart';
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

    // Clean, modern Compact Row View: clicks expand into full card
    return Card(
      color: colors.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 3.5, horizontal: 4.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.cardSecondaryTextColor.withValues(alpha: 0.14),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _isManuallyExpanded = true),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              BlocBuilder<BookmarkedIhBloc, BookmarkedIhState>(
                builder: (context, state) {
                  final bool isBookmarked = state.maybeWhen(
                    loaded: (infoHashes) =>
                        infoHashes.contains(widget.torrent.infoHash),
                    orElse: () => false,
                  );

                  return Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isBookmarked
                          ? colors.bookmarkedIconColor.withValues(alpha: 0.16)
                          : colors.cardSecondaryTextColor
                              .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: isBookmarked
                          ? Border.all(
                              color: colors.bookmarkedIconColor
                                  .withValues(alpha: 0.35),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Icon(
                      isBookmarked
                          ? Icons.folder_zip
                          : Icons.folder_zip_outlined,
                      size: 20,
                      color: isBookmarked
                          ? colors.bookmarkedIconColor
                          : colors.bookmarksSidebarSelectedTileTextColor,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
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
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          widget.torrent.size,
                          style: TextStyle(
                            color: colors.cardSecondaryTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: colors.cardSecondaryTextColor
                                .withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 13,
                          color: Colors.greenAccent[400],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.torrent.seeders,
                          style: TextStyle(
                            color: Colors.greenAccent[400],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 13,
                          color: Colors.redAccent[200],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.torrent.leechers,
                          style: TextStyle(
                            color: Colors.redAccent[200],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.torrent.date.isNotEmpty) ...[
                          Container(
                            width: 3,
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: colors.cardSecondaryTextColor
                                  .withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: colors.cardSecondaryTextColor
                                .withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              widget.torrent.date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.cardSecondaryTextColor,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.cardSecondaryTextColor.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.unfold_more_rounded,
                  size: 18,
                  color: colors.cardSecondaryTextColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
