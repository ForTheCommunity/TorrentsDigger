import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
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
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 7.0,
                          ),
                          child: TorrentListWidget(
                            torrents: state.bookmarkedTorrents,
                          ),
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
    );
  }
}
