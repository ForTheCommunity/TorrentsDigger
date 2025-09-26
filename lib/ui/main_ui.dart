import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/dig_torrent/search_torrent.dart';
import 'package:torrents_digger/ui/widgets/dropdowns_ui.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:torrents_digger/ui/widgets/search_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/settings_widgets/settings_button.dart';

class MainUi extends StatelessWidget {
  const MainUi({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    return Scaffold(
      floatingActionButton: SettingButton(),
      backgroundColor: AppColors.pureBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 55.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // SearchBar Widget
                SearchBarWidget(
                  searchController: searchController,
                  onSearchPressed: () {
                    String torrentName = searchController.text.trim();
                    final state = context.read<SourceBloc>().state;
                    String? selectedSource = state.selectedSource;
                    String? selectedFilter = state.selectedFilter;
                    String? selectedCategory = state.selectedCategory;
                    String? selectedSorting = state.selectedSorting;
                    if (torrentName.isNotEmpty) {
                      if (selectedSource != null &&
                          selectedFilter != null &&
                          selectedCategory != null &&
                          selectedSorting != null) {
                        var torrents = searchTorrent(
                          torrentName: searchController.text.trim(),
                          source: state.selectedSource!,
                          filter: state.selectedFilter!,
                          category: state.selectedCategory!,
                          sorting: state.selectedSorting!,
                        );
                      } else {
                        createSnackBar("Use Available Options... :)");
                      }
                    } else {
                      createSnackBar("Enter Torrent Name To Search... :)");
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Dropdowns Ui
                DropdownsUi(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
