import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/themes_bloc/themes_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/themes/light_theme.dart';
import 'package:torrents_digger/themes/matrix_theme.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Themes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<ThemesBloc, ThemesState>(
            builder: (context, state) {
              return state.when(
                initial: () => Center(
                  child: Text(
                    'No Trackers List Loaded Yet...',
                    style: TextStyle(color: context.appColors.generalTextColor),
                  ),
                ),
                loading: () => const Center(child: CircularProgressBarWidget()),

                themeState:
                    (
                      currentAppTheme,
                      currentAppThemeName,
                      currentAppThemeCode,
                    ) => Column(
                      children: [
                        ListTile(
                          leading: currentAppThemeCode == matrixThemeCode
                              ? Icon(
                                  Icons.color_lens_outlined,
                                  color: context.appColors.activeThemeIconColor,
                                )
                              : Icon(
                                  Icons.color_lens_outlined,
                                  color: context.appColors.settingsIconsColor,
                                ),
                          title: Text(
                            "Matrix",
                            style: TextStyle(
                              color: context.appColors.settingsTextColor,
                            ),
                          ),
                          onTap: () {
                            context.read<ThemesBloc>().add(
                              ThemesEvent.changeTheme(appTheme: MatrixTheme()),
                            );
                          },
                        ),
                        ListTile(
                          leading: currentAppThemeCode == lightThemeCode
                              ? Icon(
                                  Icons.color_lens_outlined,
                                  color: context.appColors.activeThemeIconColor,
                                )
                              : Icon(
                                  Icons.color_lens_outlined,
                                  color: context.appColors.settingsIconsColor,
                                ),
                          title: Text(
                            "Light",
                            style: TextStyle(
                              color: context.appColors.settingsTextColor,
                            ),
                          ),
                          onTap: () {
                            context.read<ThemesBloc>().add(
                              ThemesEvent.changeTheme(appTheme: LightTheme()),
                            );
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
