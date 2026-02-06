import 'package:flutter/services.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:url_launcher/url_launcher.dart';

enum UrlType { magentLink, normalLink }

Future<void> openUrl({
  required UrlType urlType,
  required bool clipboardCopy,
  required String url,
}) async {
  final uri = Uri.parse(url);

  if (clipboardCopy == true) {
    try {
      await Clipboard.setData(ClipboardData(text: url));

      if (urlType == UrlType.magentLink) {
        createSnackBar(
          message:
              "Magnet Link Copied to Clipboard.\nOpening Torrent Downloader...",
          duration: 1,
        );
        await Future.delayed(Duration(seconds: 2));
      }
    } catch (e) {
      if (urlType == UrlType.magentLink) {
        createSnackBar(
          message: "Unable to Copy Magnet Link to Clipboard",
          duration: 5,
        );
      }
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (urlType == UrlType.magentLink) {
        createSnackBar(
          message: "Unable to open torrent downloader.\nInstall Torrent App.",
          duration: 5,
        );
      }

      if (urlType == UrlType.normalLink) {
        createSnackBar(message: "Unable to open url...", duration: 5);
      }
    }
  }

  if (clipboardCopy == false) {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (urlType == UrlType.magentLink) {
        createSnackBar(
          message: "Unable to open torrent downloader.\nInstall Torrent App.",
          duration: 5,
        );
      }

      if (urlType == UrlType.normalLink) {
        createSnackBar(message: "Unable to open url...", duration: 5);
      }
    }
  }
}
