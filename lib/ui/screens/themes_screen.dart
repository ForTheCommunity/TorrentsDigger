import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/themes_bloc/themes_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/themes/themes.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ThemesBloc>().add(const ThemesEvent.loadTheme());
  }

  String _getThemeDescription(String themeCode) {
    switch (themeCode) {
      case lightThemeCode:
        return "Clean & bright appearance";
      case darkThemeCode:
        return "Modern slate dark theme";
      case matrixThemeCode:
        return "Classic terminal hacker green";
      case amoledThemeCode:
        return "Pure pitch black for OLED displays";
      default:
        return "Custom application theme";
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Themes',
          style: TextStyle(color: colors.appBarTextColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<ThemesBloc, ThemesState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressBarWidget()),
            loading: () => const Center(child: CircularProgressBarWidget()),
            themeState:
                (currentAppTheme, currentAppThemeName, currentAppThemeCode) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        itemCount: availableThemes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final theme = availableThemes[index];
                          final bool isSelected =
                              currentAppThemeCode == theme.themeCode;

                          return Card(
                            color: colors.contributeCardBackgroundColor,
                            shadowColor: colors.contributeCardShadowColor,
                            elevation: isSelected ? 3 : 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected
                                    ? colors.activeThemeIconColor
                                    : Colors.transparent,
                                width: isSelected ? 1.8 : 0,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                if (!isSelected) {
                                  context.read<ThemesBloc>().add(
                                    ThemesEvent.changeTheme(appTheme: theme),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    // Theme color palette preview swatch
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: theme.scaffoldColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey.withValues(
                                            alpha: 0.35,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _colorDot(theme.cardColor),
                                          const SizedBox(width: 3),
                                          _colorDot(
                                            theme.settingsIconsColor,
                                          ),
                                          const SizedBox(width: 3),
                                          _colorDot(
                                            theme.seedersIconColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Theme Title & Description
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            theme.themeName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: colors.settingsTextColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _getThemeDescription(
                                              theme.themeCode,
                                            ),
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: colors.settingsTextColor
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Active checkmark indicator
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: colors.activeThemeIconColor,
                                        size: 24,
                                      )
                                    else
                                      Icon(
                                        Icons.radio_button_unchecked_rounded,
                                        color: colors.settingsIconsColor
                                            .withValues(alpha: 0.35),
                                        size: 22,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
          );
        },
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 12,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
