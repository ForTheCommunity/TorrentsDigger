import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/dig_torrent/search_torrent.dart';
import 'package:torrents_digger/dig_torrent/sources_and_categories.dart';
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

  late Map<String, List<String>> _sourcesCategoryMap;
  bool _isSourcesCategoriesDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // setting initial values for the dropdowns
    // Fetch the data asynchronously when the widget is initialized
    _fetchSourcesAndCategories();
  }

  Future<void> _fetchSourcesAndCategories() async {
    try {
      final Map<String, List<String>> data = await getSourcesAndCategories();
      setState(() {
        _sourcesCategoryMap = data;
        _selectedSource = _sourcesCategoryMap.keys.first;
        _updateCategories();
        _isSourcesCategoriesDataLoaded = true;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  // method to update the list of categories
  void _updateCategories() {
    setState(() {
      _categories = _sourcesCategoryMap[_selectedSource]!;
      _selectedCategory = _categories.first;
    });
  }

  // search function that passes all data
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
                // show loading indicator until data is fetched
                _isSourcesCategoriesDataLoaded
                    ? SourcesAndCategoriesDropdown(
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
                        categoryMap: _sourcesCategoryMap,
                      )
                    : const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
