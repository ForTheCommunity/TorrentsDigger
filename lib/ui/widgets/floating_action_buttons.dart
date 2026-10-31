import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/routes/routes_name.dart';
import 'package:torrents_digger/ui/widgets/scroll_to_top_button.dart';

class FloatingActionsButtons extends StatelessWidget {
  final bool scrollToTop;
  final bool enableAddTorrent;
  final bool enableCustoms;
  final bool enableBookmarks;
  final bool enableSettings;
  final ScrollController? scrollController;

  const FloatingActionsButtons({
    super.key,
    required this.scrollToTop,
    required this.enableAddTorrent,
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

        if (enableAddTorrent) ...[
          FloatingActionButton(
            heroTag: "Add Torrent",
            mini: true,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
            tooltip: "Add Torrent",
            foregroundColor:
                context.appColors.settingsFloatingActionButtonForegroundColor,
            backgroundColor:
                context.appColors.settingsFloatingActionButtonBackgroundColor,
            hoverColor: context
                .appColors
                .settingsFloatingActionButtonHoverBackgroundColor,
            child: Icon(Icons.add_outlined),
            onPressed: () {
              Navigator.pushNamed(context, RoutesName.addTorrentScreen);
            },
          ),
          const SizedBox(height: 8),
        ],

        if (enableCustoms) ...[
          FloatingActionButton(
            heroTag: "customs",
            mini: true,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
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
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
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
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
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
