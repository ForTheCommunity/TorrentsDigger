import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/database/get_settings_data.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

enum TrackerUpdateChoice { activeOnly, allLists }

class AdditionalSettings extends StatefulWidget {
  const AdditionalSettings({super.key});

  @override
  State<AdditionalSettings> createState() => _AdditionalSettingsState();
}

class _AdditionalSettingsState extends State<AdditionalSettings> {
  bool _useInAppBrowser = true;
  bool _checkUpdatesOnStartup = true;
  bool _isLoading = true;
  bool _isUpdatingTrackers = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final val = await getUseInAppBrowser();
    final autoUpdateVal = await getAutoCheckUpdates();
    if (mounted) {
      setState(() {
        _useInAppBrowser = val;
        _checkUpdatesOnStartup = autoUpdateVal;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleInAppBrowser(bool value) async {
    setState(() {
      _useInAppBrowser = value;
    });
    await setUseInAppBrowser(value);
  }

  Future<void> _toggleCheckUpdatesOnStartup(bool value) async {
    setState(() {
      _checkUpdatesOnStartup = value;
    });
    await setAutoCheckUpdates(value);
  }

  Future<void> _handleUpdateTrackers() async {
    if (_isUpdatingTrackers) return;

    final choice = await showDialog<TrackerUpdateChoice>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: dialogContext.appColors.aboutDialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: dialogContext.appColors.settingsIconsColor
                  .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.cloud_sync_outlined,
                color: dialogContext.appColors.settingsIconsColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Update Trackers',
                  style: TextStyle(
                    color: dialogContext.appColors.settingsTextColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fetch the latest tracker lists from upstream. Which lists would you like to update?',
                style: TextStyle(
                  color: dialogContext.appColors.settingsTextColor
                      .withValues(alpha: 0.85),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () =>
                    Navigator.pop(dialogContext, TrackerUpdateChoice.activeOnly),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: dialogContext.appColors.settingsIconsColor
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bolt,
                        color: Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active List Only',
                              style: TextStyle(
                                color: dialogContext.appColors.settingsTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Fast (~1s). Updates only your currently selected tracker list.',
                              style: TextStyle(
                                color: dialogContext.appColors.settingsTextColor
                                    .withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () =>
                    Navigator.pop(dialogContext, TrackerUpdateChoice.allLists),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: dialogContext.appColors.settingsIconsColor
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.library_books_outlined,
                        color: Colors.lightBlueAccent,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Tracker Lists',
                              style: TextStyle(
                                color: dialogContext.appColors.settingsTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Downloads and refreshes all available tracker lists.',
                              style: TextStyle(
                                color: dialogContext.appColors.settingsTextColor
                                    .withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: dialogContext.appColors.settingsTextColor
                      .withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (choice == null || !mounted) return;

    setState(() {
      _isUpdatingTrackers = true;
    });

    createSnackBar(
      message: choice == TrackerUpdateChoice.allLists
          ? 'Updating all tracker lists...'
          : 'Updating active tracker list...',
      duration: 2,
    );

    try {
      final message = await updateTrackers(
        updateAll: choice == TrackerUpdateChoice.allLists,
      );
      if (mounted) {
        createSnackBar(message: message, duration: 4);
      }
    } catch (e) {
      if (mounted) {
        createSnackBar(
          message: 'Failed to update trackers: $e',
          duration: 5,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingTrackers = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Additional Settings',
          style: TextStyle(color: context.appColors.appBarTextColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          BlocBuilder<SourceBloc, SourceState>(
            builder: (context, state) {
              return Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      Icons.explicit_outlined,
                      color: context.appColors.settingsIconsColor,
                    ),
                    title: Text(
                      'Hide NSFW',
                      style: TextStyle(color: context.appColors.settingsTextColor),
                    ),
                    subtitle: Text(
                      'Hide adult content sources and categories across the app.',
                      style: TextStyle(
                        color: context.appColors.settingsTextColor,
                        fontSize: 12,
                      ),
                    ),
                    inactiveTrackColor: context
                        .appColors.settingsSwitchListTileInactiveTrackColor,
                    inactiveThumbColor: context
                        .appColors.settingsSwitchListTileInactiveThumbColor,
                    activeThumbColor: context
                        .appColors.settingsSwitchListTileActiveThumbColor,
                    value: state.hideNsfw,
                    onChanged: (value) {
                      context.read<SourceBloc>().add(ToggleHideNsfw(value));
                    },
                  ),
                  SwitchListTile(
                    secondary: Icon(
                      Icons.manage_history_outlined,
                      color: context.appColors.settingsIconsColor,
                    ),
                    title: Text(
                      'Remember Selections',
                      style: TextStyle(color: context.appColors.settingsTextColor),
                    ),
                    subtitle: Text(
                      'Remember selected category, filter, etc for each source.',
                      style: TextStyle(
                        color: context.appColors.settingsTextColor,
                        fontSize: 12,
                      ),
                    ),
                    inactiveTrackColor: context
                        .appColors.settingsSwitchListTileInactiveTrackColor,
                    inactiveThumbColor: context
                        .appColors.settingsSwitchListTileInactiveThumbColor,
                    activeThumbColor: context
                        .appColors.settingsSwitchListTileActiveThumbColor,
                    value: state.rememberSelections,
                    onChanged: (value) {
                      context.read<SourceBloc>().add(
                            ToggleRememberSelections(value),
                          );
                    },
                  ),
                ],
              );
            },
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.language_outlined,
              color: context.appColors.settingsIconsColor,
            ),
            title: Text(
              'In-App Browser',
              style: TextStyle(color: context.appColors.settingsTextColor),
            ),
            subtitle: Text(
              'Open links inside the app using an in-app WebView instead of an external browser.',
              style: TextStyle(
                color: context.appColors.settingsTextColor,
                fontSize: 12,
              ),
            ),
            inactiveTrackColor:
                context.appColors.settingsSwitchListTileInactiveTrackColor,
            inactiveThumbColor:
                context.appColors.settingsSwitchListTileInactiveThumbColor,
            activeThumbColor:
                context.appColors.settingsSwitchListTileActiveThumbColor,
            value: _useInAppBrowser,
            onChanged: _isLoading ? null : _toggleInAppBrowser,
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.update_outlined,
              color: context.appColors.settingsIconsColor,
            ),
            title: Text(
              'Check Updates on Startup',
              style: TextStyle(color: context.appColors.settingsTextColor),
            ),
            subtitle: Text(
              'Automatically check if a new version is available when opening the app.',
              style: TextStyle(
                color: context.appColors.settingsTextColor,
                fontSize: 12,
              ),
            ),
            inactiveTrackColor:
                context.appColors.settingsSwitchListTileInactiveTrackColor,
            inactiveThumbColor:
                context.appColors.settingsSwitchListTileInactiveThumbColor,
            activeThumbColor:
                context.appColors.settingsSwitchListTileActiveThumbColor,
            value: _checkUpdatesOnStartup,
            onChanged: _isLoading ? null : _toggleCheckUpdatesOnStartup,
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.cloud_sync_outlined,
              color: context.appColors.settingsIconsColor,
            ),
            title: Text(
              'Update Trackers',
              style: TextStyle(color: context.appColors.settingsTextColor),
            ),
            subtitle: Text(
              'Download the latest peer tracker lists from upstream to discover active peers.',
              style: TextStyle(
                color: context.appColors.settingsTextColor,
                fontSize: 12,
              ),
            ),
            trailing: _isUpdatingTrackers
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.appColors.settingsIconsColor,
                    ),
                  )
                : null,
            onTap: _isUpdatingTrackers ? null : _handleUpdateTrackers,
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.cleaning_services_outlined,
              color: context.appColors.settingsIconsColor,
            ),
            title: Text(
              'Reset Cloudflare Cookies & User-Agent',
              style: TextStyle(color: context.appColors.settingsTextColor),
            ),
            subtitle: Text(
              'Clear stored Cloudflare clearance tokens and reset User-Agent to default. Useful if search requests fail with Cloudflare errors.',
              style: TextStyle(
                color: context.appColors.settingsTextColor,
                fontSize: 12,
              ),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    backgroundColor:
                        dialogContext.appColors.aboutDialogBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: dialogContext.appColors.settingsIconsColor
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    title: Row(
                      children: [
                        Icon(
                          Icons.cleaning_services_outlined,
                          color: dialogContext.appColors.settingsIconsColor,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Reset Cloudflare Session?',
                            style: TextStyle(
                              color: dialogContext.appColors.settingsTextColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'This will clear all stored Cloudflare clearance cookies and reset the app User-Agent back to default. You will be prompted to resolve challenges again if required.',
                      style: TextStyle(
                        color: dialogContext.appColors.settingsTextColor
                            .withValues(alpha: 0.85),
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: dialogContext.appColors.settingsTextColor
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                final count = await clearAllCloudflareCookies();
                await resetAppUserAgent();
                createSnackBar(
                  message:
                      'Reset complete: Cleared $count Cloudflare cookie(s) & reset User-Agent.',
                  duration: 3,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
