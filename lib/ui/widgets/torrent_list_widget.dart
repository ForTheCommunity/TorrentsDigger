import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/configs/global_key.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:url_launcher/url_launcher.dart';

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
        return _buildTorrentCard(torrent);
      },
    );
  }

  Widget _buildTorrentCard(InternalTorrent torrent) {
    return Card(
      color: AppColors.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              torrent.name,
              style: TextStyle(
                color: AppColors.cardPrimaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16,
                  color: AppColors.cardSecondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  torrent.size,
                  style: TextStyle(color: AppColors.cardSecondaryTextColor),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.upload_sharp,
                  size: 16,
                  color: AppColors.seedersIconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Seeders : ${torrent.seeders}',
                  style: TextStyle(color: AppColors.seedersTextColor),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.download,
                  size: 16,
                  color: AppColors.leechersIconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Leechers : ${torrent.leechers}',
                  style: TextStyle(
                    color: AppColors.leechersTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(12),
                    // border: Border.all(
                    color: AppColors.magnetBackgroundColor,
                    //   width: 1.0,
                    // ),
                  ),
                  child: Padding(
                    padding: EdgeInsetsGeometry.directional(
                      start: 15,
                      end: 15,
                      top: 3,
                      bottom: 3,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final Uri magnetUri = Uri.parse(torrent.magnetLink);
                            if (await canLaunchUrl(magnetUri)) {
                              await launchUrl(magnetUri);
                            } else {
                              // Use the global key to show the SnackBar
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                  content: Text('Could not launch Magnet Link'),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 30,
                                  color: AppColors.magnetIconColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Magnet",
                                  style: TextStyle(
                                    color: AppColors.magnetForegroundColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
