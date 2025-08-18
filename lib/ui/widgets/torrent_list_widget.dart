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
            const SizedBox(height: 10),
            Text(
              torrent.name,
              style: TextStyle(
                color: AppColors.cardPrimaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
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
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.date_range_sharp,
                  size: 20,
                  color: AppColors.cardSecondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Created at : ${torrent.date}',
                  style: TextStyle(
                    color: AppColors.cardSecondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.upload_sharp,
                      size: 20,
                      color: AppColors.seedersIconColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Seeders : ${torrent.seeders}',
                      style: TextStyle(
                        color: AppColors.seedersTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.download,
                      size: 20,
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
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.download_for_offline,
                  size: 20,
                  color: AppColors.cardSecondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Total Downloads : ${torrent.totalDownloads}',
                  style: TextStyle(
                    color: AppColors.cardSecondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final Uri magnetUri = Uri.parse(torrent.magnetLink);
                    if (await canLaunchUrl(magnetUri)) {
                      await launchUrl(magnetUri);
                    } else {
                      scaffoldMessengerKey.currentState?.showSnackBar(
                        const SnackBar(content: Text('Install Torrent App.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    surfaceTintColor: AppColors.magnetButtonSurfaceTintColor,
                    backgroundColor: AppColors.magnetBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
