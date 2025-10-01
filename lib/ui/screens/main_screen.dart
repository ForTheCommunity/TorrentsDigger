import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/blocs/torrent_bloc/torrent_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/ui/widgets/dropdowns_ui.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:torrents_digger/ui/widgets/search_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/settings_widgets/settings_button.dart';
import 'package:torrents_digger/ui/widgets/torrents_list_ui.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    return Scaffold(
      floatingActionButton: SettingButton(),
      backgroundColor: AppColors.pureBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // SearchBar Widget
                SearchBarWidget(
                  searchController: searchController,
                  onSearchPressed: () {
                    String torrentName = searchController.text.trim();
                    final sourceState = context.read<SourceBloc>().state;

                    if (torrentName.isNotEmpty) {
                      if (sourceState.selectedSource != null) {
                        final details = sourceState.selectedDetails!;
                        final bool categoriesOk =
                            !details.queryOptions.categories ||
                            (details.queryOptions.categories &&
                                sourceState.selectedCategory != null);
                        final bool filtersOk =
                            !details.queryOptions.filters ||
                            (details.queryOptions.filters &&
                                sourceState.selectedFilter != null);
                        final bool sortingsOk =
                            !details.queryOptions.sortings ||
                            (details.queryOptions.sortings &&
                                sourceState.selectedSorting != null);

                        if (!categoriesOk || !filtersOk || !sortingsOk) {
                          createSnackBar(
                            message: "Use Available Options... :)",
                            duration: 2,
                          );
                          return;
                        }

                        context.read<TorrentBloc>().add(
                          SearchTorrents(
                            torrentName: torrentName,
                            source: sourceState.selectedSource!,
                            filter: sourceState.selectedFilter ?? "",
                            category: sourceState.selectedCategory ?? "",
                            sorting: sourceState.selectedSorting ?? "",
                          ),
                        );
                      } else {
                        createSnackBar(
                          message: "Use Available Options... :)",
                          duration: 2,
                        );
                      }
                    } else {
                      createSnackBar(
                        message: "Enter Torrent Name To Search... :)",
                        duration: 2,
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Dropdowns Ui
                DropdownsUi(),

                const SizedBox(height: 24),
                const TorrentsListUi(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
