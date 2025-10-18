import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/settings_bloc/settings_bloc.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:url_launcher/url_launcher.dart';

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
              createSnackBar(message: errorMessage, duration: 10);
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
                    var url = Uri.parse(
                      "https://gitlab.com/ForTheCommunity/torrentsdigger",
                    );
                    if (!await launchUrl(url)) {
                      createSnackBar(
                        message: 'Unable to open Link.',
                        duration: 2,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.code),
                      SizedBox(width: 5),
                      Text("Source Code (Main Repo)"),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () async {
                    var url = Uri.parse(
                      "https://github.com/ForTheCommunity/torrentsdigger",
                    );
                    if (!await launchUrl(url)) {
                      createSnackBar(
                        message: 'Unable to open Link.',
                        duration: 2,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.code),
                      SizedBox(width: 5),
                      Text("Source Code (Mirror Repo)"),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () async {
                    var url = Uri.parse(
                      "https://gitlab.com/ForTheCommunity/torrentsdigger#license",
                    );
                    if (!await launchUrl(url)) {
                      createSnackBar(
                        message: 'Unable to open Link.',
                        duration: 2,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.gavel),
                      SizedBox(width: 5),
                      Text("License"),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () async {
                    var url = Uri.parse(
                      "https://gitlab.com/ForTheommunity/torrentsdigger/-/issues",
                    );
                    if (!await launchUrl(url)) {
                      createSnackBar(
                        message: 'Unable to open Link.',
                        duration: 2,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.bug_report),
                      SizedBox(width: 5),
                      Text("Issues"),
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
