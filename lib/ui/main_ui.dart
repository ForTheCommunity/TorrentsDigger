import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/ui/widgets/dropdowns_ui.dart';
import 'package:torrents_digger/ui/widgets/search_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/settings_widgets/settings_button.dart';

class MainUi extends StatelessWidget {
  const MainUi({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    return BlocProvider(
      create: (context) => SourceBloc()..add(LoadSources()),
      child: Scaffold(
        floatingActionButton: SettingButton(),
        backgroundColor: AppColors.pureBlack,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 55.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // SearchBar Widget
                  SearchBarWidget(
                    searchController: searchController,
                    onSearchPressed: () {
                      final state = context.read<SourceBloc>().state;
                      debugPrint("Search Button Pressed");
                      debugPrint("Selected Source : ${state.selectedSource}");
                      debugPrint(
                        "Selected Category : ${state.selectedCategory}",
                      );
                      debugPrint("Selected Filter : ${state.selectedFilter}");
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
      ),
    );
  }
}
