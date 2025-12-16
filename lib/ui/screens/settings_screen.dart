import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/settings_bloc/settings_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';
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
              title: const Text('Settings'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
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
                      leading: const Icon(Icons.hub),
                      title: const Text('Default Trackers'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RoutesName.defaultTrackersScreen,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_ethernet),
                      title: const Text('Proxy'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RoutesName.proxySettingScreen,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.import_export),
                      title: const Text('Database'),
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.databaseScreen);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.color_lens_outlined),
                      title: const Text("Theme"),
                      onTap: () {
                        Navigator.pushNamed(context, RoutesName.themesScreen);
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
                            orElse: () => const Icon(Icons.update),
                          ),
                          title: const Text('Check For Update'),
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
                      leading: const Icon(Icons.details),
                      title: const Text('About'),
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
