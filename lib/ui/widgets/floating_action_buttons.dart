import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/routes/routes_name.dart';
import 'package:torrents_digger/ui/widgets/scroll_to_top_button.dart';

class FloatingActionsButtons extends StatelessWidget {
  final bool scrollToTop;
  final bool enableCustoms;
  final bool enableBookmarks;
  final bool enableSettings;
  final ScrollController? scrollController;

  const FloatingActionsButtons({
    super.key,
    required this.scrollToTop,
    required this.enableCustoms,
    required this.enableBookmarks,
    required this.enableSettings,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (scrollToTop) ...[
          ScrollToTopButton(
            scrollController:
                scrollController ?? PrimaryScrollController.of(context),
          ),
          const SizedBox(height: 10),
        ],

        if (enableCustoms) ...[
          FloatingActionButton(
            heroTag: "customs",
            mini: true,
            tooltip: 'Customs',
            foregroundColor:
                context.appColors.settingsFloatingActionButtonForegroundColor,
            backgroundColor:
                context.appColors.settingsFloatingActionButtonBackgroundColor,
            hoverColor: context
                .appColors
                .settingsFloatingActionButtonHoverBackgroundColor,
            child: const Icon(Icons.dashboard_customize_outlined),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesName.customsScreen,
                (route) => route.isFirst, // keeps only the first/main screen
              );
            },
          ),

          const SizedBox(height: 8),
        ],

        if (enableBookmarks) ...[
          FloatingActionButton(
            heroTag: "bookmarks",
            mini: true,
            tooltip: 'Bookmarks',
            foregroundColor:
                context.appColors.settingsFloatingActionButtonForegroundColor,
            backgroundColor:
                context.appColors.settingsFloatingActionButtonBackgroundColor,
            hoverColor: context
                .appColors
                .settingsFloatingActionButtonHoverBackgroundColor,
            child: const Icon(Icons.bookmarks_outlined),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesName.bookmarksScreen,
                (route) => route.isFirst, // keeps only the first/main screen
              );
            },
          ),

          const SizedBox(height: 8),
        ],

        if (enableSettings) ...[
          FloatingActionButton(
            tooltip: 'Settings',
            foregroundColor:
                context.appColors.settingsFloatingActionButtonForegroundColor,
            backgroundColor:
                context.appColors.settingsFloatingActionButtonBackgroundColor,
            hoverColor: context
                .appColors
                .settingsFloatingActionButtonHoverBackgroundColor,
            child: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesName.settingsScreen,
                (route) => route.isFirst, // keeps only the first/main screen
              );
            },
          ),
        ],
      ],
    );
  }
}
