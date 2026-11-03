import 'package:flutter/material.dart';
import 'package:torrents_digger/database/get_settings_data.dart';
import 'package:torrents_digger/ui/screens/source_webview_screen.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

enum UrlType { magentLink, normalLink }

Future<void> openUrl({
  required UrlType urlType,
  required String url,
  String? title,
  BuildContext? context,
  @Deprecated('Clipboard copy is removed from openUrl')
  bool? clipboardCopy,
}) async {
  if (urlType == UrlType.normalLink) {
    try {
      final useInApp = await getUseInAppBrowser();
      if (useInApp) {
        final nav = (context != null && context.mounted)
            ? Navigator.of(context)
            : navigatorKey.currentState;
        if (nav != null) {
          await nav.push(
            MaterialPageRoute(
              builder: (_) => SourceWebViewScreen(url: url, title: title),
            ),
          );
          return;
        }
      }
    } catch (_) {
      // Fallback to external application below if in-app navigation fails
    }
  }

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
