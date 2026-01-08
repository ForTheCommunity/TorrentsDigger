import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/settings_bloc/settings_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/launch_url.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        state.whenOrNull(
          loadCurrentVersionError: (errorMessage) {
            createSnackBar(message: errorMessage, duration: 5);
          },
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          loadingCurrentVersion: () =>
              const Center(child: CircularProgressBarWidget()),
          loadCurrentVersionError: (error) =>
              const AboutAlertDialog(appVersion: "Error Loading Version"),
          orElse: () {
            final appVersion = state.maybeWhen(
              loadedCurrentVersion: (currentVersion) => currentVersion,
              orElse: () => 'Loading App Version',
            );

            return AboutAlertDialog(appVersion: appVersion);
          },
        );
      },
    );
  }
}

class AboutAlertDialog extends StatelessWidget {
  const AboutAlertDialog({super.key, required this.appVersion});
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.appColors.aboutDialogBackgroundColor,
      title: Text(
        'Torrents Digger',
        style: TextStyle(color: context.appColors.aboutDialogTextColor),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(
              'Version : $appVersion',
              style: TextStyle(color: context.appColors.aboutDialogTextColor),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                openUrl(
                  urlType: UrlType.normalLink,
                  clipboardCopy: false,
                  url: "https://gitlab.com/ForTheCommunity/torrentsdigger",
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.code,
                    color: context.appColors.aboutDialogIconColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Source Code (Main Repo)",
                    style: TextStyle(
                      color: context.appColors.aboutDialogHyperlinkTextColor,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                openUrl(
                  urlType: UrlType.normalLink,
                  clipboardCopy: false,
                  url: "https://github.com/ForTheCommunity/torrentsdigger",
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.code,
                    color: context.appColors.aboutDialogIconColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Source Code (Mirror Repo)",
                    style: TextStyle(
                      color: context.appColors.aboutDialogHyperlinkTextColor,
                    ),
                  ),
                ],
              ),
            ),

            TextButton(
              onPressed: () async {
                openUrl(
                  urlType: UrlType.normalLink,
                  clipboardCopy: false,
                  url:
                      "https://gitlab.com/ForTheCommunity/torrentsdigger/-/issues",
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.bug_report,
                    color: context.appColors.aboutDialogIconColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Issues",
                    style: TextStyle(
                      color: context.appColors.aboutDialogHyperlinkTextColor,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                openUrl(
                  urlType: UrlType.normalLink,
                  clipboardCopy: false,
                  url: "https://matrix.to/#/#forthecommunity_space:matrix.org"
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.chat_outlined,
                    color: context.appColors.aboutDialogIconColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Matrix Chat Room",
                    style: TextStyle(
                      color: context.appColors.aboutDialogHyperlinkTextColor,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                openUrl(
                  urlType: UrlType.normalLink,
                  clipboardCopy: false,
                  url:
                      "https://gitlab.com/ForTheCommunity/torrentsdigger#license",
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.gavel,
                    color: context.appColors.aboutDialogIconColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "License",
                    style: TextStyle(
                      color: context.appColors.aboutDialogHyperlinkTextColor,
                    ),
                  ),
                ],
              ),
            ),

            TextButton(
              onPressed: () {
                showLicensePage(
                  context: context,
                  applicationName: 'Torrents Digger',
                  applicationVersion: 'Version : $appVersion',
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.gavel_rounded,
                    color: context.appColors.aboutDialogIconColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Other Open Source Licenses",
                    style: TextStyle(
                      color: context.appColors.aboutDialogHyperlinkTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Close",
            style: TextStyle(
              color: context.appColors.aboutDialogHyperlinkTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
