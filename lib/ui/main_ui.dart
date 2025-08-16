import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/dig_torrent/search_torrent.dart';
import 'package:torrents_digger/ui/widgets/sources_and_categories_dropdown.dart';
import 'package:torrents_digger/ui/widgets/search_bar_widget.dart';

class MainUi extends StatefulWidget {
  const MainUi({super.key});

  @override
  State<MainUi> createState() => _MainUiState();
}

class _MainUiState extends State<MainUi> {
  // variables to hold state of search bar and dropdown menus
  final TextEditingController _searchController = TextEditingController();
  late String _selectedSource;
  late String _selectedCategory;
  List<String> _categories = [];

  // Sample data for categories and their sub-categories
  final Map<String, List<String>> _categoryMap = {
    "Nyaa": [
      "All Categories",
      "Anime",
      "Anime Music Video",
      "Anime English Translated",
      "Anime Non English Translated",
      "Anime Raw",
      "Audio",
      "Audio Lossless",
      "Audio Lossy",
      "Literature",
      "Literature English Translated",
      "Literature Non English Translated",
      "Literature Raw",
      "Live Action",
      "Live Action English Translated",
      "Live Action Idol Promotional Video",
      "Live Action Non English Translated",
      "Live Action Raw",
      "Pictures",
      "Pictures Graphics",
      "Pictures Photos",
      "Software",
      "Software Applications",
      "Software Games",
    ],
    'Movies': ['Action', 'Comedy', 'Horror', 'Sci-Fi'],
    'TV Shows': ['Drama', 'Comedy', 'Animated'],
    'Music': ['Pop', 'Rock', 'Electronic', 'Classical'],
    'Games': ['Adventure', 'RPG', 'Strategy', 'Simulation'],
    'Software': ['Operating Systems', 'Applications', 'Utilities'],
  };

  @override
  void initState() {
    super.initState();
    // setting initial values for the dropdowns
    _selectedSource = _categoryMap.keys.first;
    _updateCategories();
  }

  // method to update the list of categories
  void _updateCategories() {
    setState(() {
      _categories = _categoryMap[_selectedSource]!;
      _selectedCategory = _categories.first;
    });
  }

  // The main search function that passes all data
  void _onSearchPressed() {
    debugPrint("BUTTON PRESSED");
    searchTorrent(
      torrentName: _searchController.text,
      source: _selectedSource,
      category: _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                SearchBarWidget(
                  searchController: _searchController,
                  onSearchPressed: _onSearchPressed,
                ),
                const SizedBox(height: 24),
                SourcesAndCategoriesDropdown(
                  selectedSource: _selectedSource,
                  selectedCategory: _selectedCategory,
                  categories: _categories,

                  onSourceChanged: (String? newValue) {
                    setState(() {
                      _selectedSource = newValue!;
                      _updateCategories();
                    });
                  },

                  onCategoryChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  categoryMap: _categoryMap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// works perfectly

// import 'package:flutter/material.dart';
// import 'package:torrents_digger/configs/colors.dart';
// import 'package:torrents_digger/ui/widgets/sources_and_categories_dropdown.dart';
// import 'package:torrents_digger/ui/widgets/search_bar_widget.dart';

// class MainUi extends StatefulWidget {
//   const MainUi({super.key});

//   @override
//   State<MainUi> createState() => _MainUiState();
// }

// class _MainUiState extends State<MainUi> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.pureBlack,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 50.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 16),
//                 SearchBarWidget(),
//                 const SizedBox(height: 24),
//                 SourcesAndCategoriesDropdown(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
