import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/scroll_to_top_button.dart';
import 'package:torrents_digger/ui/widgets/settings_button.dart';
import 'package:torrents_digger/ui/widgets/torrent_list_widget.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    // load bookmarks when the screen is initialized
    context.read<BookmarkBloc>().add(LoadBookmarkedTorrentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: TextStyle(
            color: context.appColors.appBarTextColor,
            letterSpacing: 2,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
        ),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScrollToTopButton(
            scrollController: PrimaryScrollController.of(context),
          ),
          const SizedBox(height: 10),
          SettingButton(),
        ],
      ),

      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            primary: true,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: Platform.isLinux || Platform.isWindows || Platform.isMacOS
                    ? 15
                    : (Platform.isAndroid || Platform.isIOS ? 7.0 : 7.0),
              ),

              child: BlocBuilder<BookmarkBloc, BookmarkState>(
                builder: (context, state) {
                  switch (state) {
                    case BookmarkInitialState():
                      // Show a loading indicator while in the initial state
                      // as we are dispatching the load event immediately.
                      return const Center(child: CircularProgressBarWidget());

                    case BookmarksLoadingState():
                      return const Center(child: CircularProgressBarWidget());

                    case BookmarksLoadedState():
                      return state.bookmarkedTorrents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10),
                                  Text(
                                    "Bookmark Torrents to save it for later.",
                                    style: TextStyle(
                                      color: context.appColors.generalTextColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : TorrentListWidget(
                              torrents: state.bookmarkedTorrents,
                            );

                    case BookmarksLoadFailedState():
                      return Center(
                        child: Text(
                          "Failed to fetch Torrents \n Error : ${state.error}",
                        ),
                      );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
