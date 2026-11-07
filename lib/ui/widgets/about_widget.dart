import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/settings_bloc/settings_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/themes/app_theme.dart';
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
    final colors = context.appColors;
    final accentColor = colors.aboutDialogIconColor;

    return AlertDialog(
      backgroundColor: colors.aboutDialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
      actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Application Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/icon.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.travel_explore_rounded,
                      size: 32,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // App Name
              Text(
                'Torrents Digger',
                style: TextStyle(
                  color: colors.aboutDialogTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),

              // Version Pill (Display Only)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: colors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.cardSecondaryTextColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  appVersion,
                  style: TextStyle(
                    color: colors.cardSecondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Group 1: Source Repositories
              _buildActionCard(
                colors: colors,
                children: [
                  _buildActionTile(
                    colors: colors,
                    icon: Icons.code_rounded,
                    title: "Source Code (Main Repo)",
                    subtitle: "GitLab • ForTheCommunity",
                    onTap: () => openUrl(
                      urlType: UrlType.normalLink,
                      clipboardCopy: false,
                      url: "https://gitlab.com/ForTheCommunity/torrentsdigger",
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: colors.cardSecondaryTextColor.withValues(
                      alpha: 0.12,
                    ),
                  ),
                  _buildActionTile(
                    colors: colors,
                    icon: Icons.code_rounded,
                    title: "Source Code (Mirror Repo)",
                    subtitle: "GitHub • ForTheCommunity",
                    onTap: () => openUrl(
                      urlType: UrlType.normalLink,
                      clipboardCopy: false,
                      url: "https://github.com/ForTheCommunity/torrentsdigger",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Group 2: Community & Issues
              _buildActionCard(
                colors: colors,
                children: [
                  _buildActionTile(
                    colors: colors,
                    icon: Icons.bug_report_rounded,
                    title: "Issue Tracker",
                    subtitle: "Bug reports & feature requests",
                    onTap: () => openUrl(
                      urlType: UrlType.normalLink,
                      clipboardCopy: false,
                      url:
                          "https://gitlab.com/ForTheCommunity/torrentsdigger/-/issues",
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: colors.cardSecondaryTextColor.withValues(
                      alpha: 0.12,
                    ),
                  ),
                  _buildActionTile(
                    colors: colors,
                    icon: Icons.chat_rounded,
                    title: "Matrix Chat Space",
                    subtitle: "#forthecommunity_space:matrix.org",
                    onTap: () => openUrl(
                      urlType: UrlType.normalLink,
                      forceExternal: true,
                      clipboardCopy: false,
                      url:
                          "https://matrix.to/#/#forthecommunity_space:matrix.org",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Group 3: Legal & Licenses
              _buildActionCard(
                colors: colors,
                children: [
                  _buildActionTile(
                    colors: colors,
                    icon: Icons.gavel_rounded,
                    title: "Project License",
                    subtitle: "Free & Open Source Software",
                    onTap: () => openUrl(
                      urlType: UrlType.normalLink,
                      clipboardCopy: false,
                      url:
                          "https://gitlab.com/ForTheCommunity/torrentsdigger#license",
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: colors.cardSecondaryTextColor.withValues(
                      alpha: 0.12,
                    ),
                  ),
                  _buildActionTile(
                    colors: colors,
                    icon: Icons.description_rounded,
                    title: "Open Source Licenses",
                    subtitle: "Third-party libraries & tools",
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'Torrents Digger',
                      applicationVersion: 'Version : $appVersion',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Center(
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor:
                  colors.bookmarkCategoryDialogCloseButtonBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: colors.bookmarkCategoryDialogCloseButtonTextColor,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required AppTheme colors,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.cardSecondaryTextColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile({
    required AppTheme colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: colors.aboutDialogIconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: colors.aboutDialogIconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.cardPrimaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 1.5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.cardSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 15,
                color: colors.cardSecondaryTextColor.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
