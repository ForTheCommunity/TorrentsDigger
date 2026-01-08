import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/settings_bloc/settings_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/routes/routes_name.dart';
import 'package:torrents_digger/ui/widgets/about_widget.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Settings',
                style: TextStyle(color: context.appColors.appBarTextColor),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(
                        color: context.appColors.settingsIconsColor,
                        Icons.color_lens_outlined,
                      ),
                      title: Text(
                        "Theme",
                        style: TextStyle(
                          color: context.appColors.settingsTextColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.themesScreen);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        color: context.appColors.settingsTextColor,
                        Icons.hub,
                      ),
                      title: Text(
                        'Default Trackers',
                        style: TextStyle(
                          color: context.appColors.settingsTextColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RoutesName.defaultTrackersScreen,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        color: context.appColors.settingsIconsColor,
                        Icons.settings_ethernet,
                      ),
                      title: Text(
                        'Proxy',
                        style: TextStyle(
                          color: context.appColors.settingsTextColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RoutesName.proxySettingScreen,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.settings_suggest_outlined,
                        size: 29.0,
                        color: context.appColors.settingsIconsColor,
                      ),
                      title: Text(
                        "Additional Settings",
                        style: TextStyle(
                          color: context.appColors.settingsTextColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RoutesName.additionalSettingsScreen,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        color: context.appColors.settingsIconsColor,
                        Icons.import_export,
                      ),
                      title: Text(
                        'Database',
                        style: TextStyle(
                          color: context.appColors.settingsTextColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.databaseScreen);
                      },
                    ),

                    BlocConsumer<SettingsBloc, SettingsState>(
                      listener: (context, state) {
                        state.whenOrNull(
                          updateAvailable: () => createSnackBar(
                            message: "New Version is Available.",
                            duration: 2,
                          ),
                          latestVersion: () => createSnackBar(
                            message: "You are using latest version...",
                            duration: 2,
                          ),
                          checkAppUpdateError: (msg) => createSnackBar(
                            message: "Error : $msg",
                            duration: 5,
                          ),
                        );
                      },
                      builder: (context, state) {
                        return ListTile(
                          leading: state.maybeWhen(
                            updateChecking: () => const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressBarWidget(),
                            ),
                            orElse: () => Icon(
                              color: context.appColors.settingsIconsColor,
                              Icons.update,
                            ),
                          ),
                          title: Text(
                            'Check For Update',
                            style: TextStyle(
                              color: context.appColors.settingsTextColor,
                            ),
                          ),
                          onTap: state.maybeWhen(
                            updateChecking: () => null,
                            orElse: () =>
                                () => context.read<SettingsBloc>().add(
                                  SettingsEvents.checkForUpdate(),
                                ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        color: context.appColors.settingsIconsColor,
                        Icons.diversity_1,
                        // Other Icons that also can be used.
                        // Icons.diversity_2,
                        // Icons.diversity_3_outlined
                        // Icons.volunteer_activism,
                        // Icons.volunteer_activism_outlined
                      ),
                      title: Text(
                        'Contribute',
                        style: TextStyle(
                          color: context.appColors.settingsTextColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RoutesName.contributeScreen,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        color: context.appColors.settingsIconsColor,
                        Icons.details,
                      ),
                      title: Text(
                        'About',
                        style: TextStyle(
                          color: context.appColors.settingsTextColor,
                        ),
                      ),
                      onTap: () {
                        final settingsBloc = context.read<SettingsBloc>();
                        settingsBloc.add(
                          const SettingsEvents.getAppCurrentVersion(),
                        );
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return BlocProvider.value(
                              value: settingsBloc,
                              child: const AboutWidget(),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
