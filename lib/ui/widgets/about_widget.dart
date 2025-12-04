import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/settings_bloc/settings_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/launch_url.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return state.maybeWhen(
          loadingCurrentVersion: () =>
              const Center(child: CircularProgressBarWidget()),
          loadCurrentVersionError: (errorMessage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              createSnackBar(message: errorMessage, duration: 5);
            });
            return const AboutDialog(
              applicationName: 'Torrents Digger',
              applicationVersion: 'Error loading version.',
            );
          },
          orElse: () {
            final appVersion = state.maybeWhen(
              loadedCurrentVersion: (currentVersion) => currentVersion,
              orElse: () => 'Loading App Version',
            );

            return AboutDialog(
              applicationName: 'Torrents Digger',
              applicationVersion: 'Version : $appVersion',
              children: [
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
                      Icon(Icons.code, color: AppColors.aboutDialogIconColor),
                      SizedBox(width: 5),
                      Text(
                        "Source Code (Main Repo)",
                        style: TextStyle(color: AppColors.aboutDialogTextColor),
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
                      Icon(Icons.code, color: AppColors.aboutDialogIconColor),
                      SizedBox(width: 5),
                      Text(
                        "Source Code (Mirror Repo)",
                        style: TextStyle(color: AppColors.aboutDialogTextColor),
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
                      Icon(Icons.gavel, color: AppColors.aboutDialogIconColor),
                      SizedBox(width: 5),
                      Text(
                        "License",
                        style: TextStyle(color: AppColors.aboutDialogTextColor),
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
                          "https://gitlab.com/ForTheommunity/torrentsdigger/-/issues",
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.bug_report,
                        color: AppColors.aboutDialogIconColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Issues",
                        style: TextStyle(color: AppColors.aboutDialogTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
