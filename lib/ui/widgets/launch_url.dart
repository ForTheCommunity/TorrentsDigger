import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:url_launcher/url_launcher.dart';

enum UrlType { magentLink, normalLink }

Future<void> openUrl({
  required UrlType urlType,
  required String url,
  @Deprecated('Clipboard copy is removed from openUrl')
  bool? clipboardCopy,
}) async {
  final uri = Uri.parse(url);

  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (urlType == UrlType.magentLink) {
        createSnackBar(
          message: "Unable to open torrent downloader.\nInstall Torrent App.",
          duration: 5,
        );
      } else if (urlType == UrlType.normalLink) {
        createSnackBar(message: "Unable to open url...", duration: 5);
      }
    }
  } catch (e) {
    if (urlType == UrlType.magentLink) {
      createSnackBar(
        message: "Unable to open torrent downloader.\nInstall Torrent App.",
        duration: 5,
      );
    } else {
      createSnackBar(message: "Unable to open url: $e", duration: 5);
    }
  }
}
