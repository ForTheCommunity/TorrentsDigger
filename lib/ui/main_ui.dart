import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/dig_torrent/search_torrent.dart';
import 'package:torrents_digger/dig_torrent/sources_and_categories.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/ui/widgets/sources_and_categories_dropdown.dart';
import 'package:torrents_digger/ui/widgets/search_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/torrent_list_widget.dart';

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
  bool _isSearching = false;
  List<InternalTorrent> _torrentsList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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
  Future<void> _onSearchPressed() async {
    debugPrint("BUTTON PRESSED");
    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _torrentsList = [];
    });
    try {
      final results = await searchTorrent(
        torrentName: _searchController.text,
        source: _selectedSource,
        category: _selectedCategory,
      );
      setState(() {
        _torrentsList = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
                const SizedBox(height: 25),
                if (_isSearching)
                  const Center(child: CircularProgressIndicator())
                else if (_torrentsList.isNotEmpty)
                  TorrentListWidget(torrents: _torrentsList)
                else if (_errorMessage != null)
                  Center(
                    child: Text(
                      "Error : \n $_errorMessage \n[Errors Are UnHandled at the moment(TODO)]",
                      style: const TextStyle(
                        color: AppColors.brightRed,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  const Center(
                    child: Text(
                      'Search Torrent, Get Torrents.',
                      style: TextStyle(
                        color: AppColors.categoryLabelColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
