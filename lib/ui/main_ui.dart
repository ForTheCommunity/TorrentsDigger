import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/temp/search_torrent.dart';

class MainUi extends StatefulWidget {
  const MainUi({super.key});

  @override
  State<MainUi> createState() => _MainUiState();
}

class _MainUiState extends State<MainUi> {
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
                _buildSearchBar(),
                // const SizedBox(height: 24),
                // _buildCategoryChips(),
                // const SizedBox(height: 24),
                // _buildTorrentList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Search Bar Widget
Widget _buildSearchBar() {
  TextEditingController searchController = TextEditingController();
  return Container(
    decoration: BoxDecoration(
      color: AppColors.searchBarBackgroundColor,
      borderRadius: BorderRadius.circular(12),
    ),

    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Row(
      children: [
        Text("⮞ ", style: TextStyle(color: AppColors.greenColor, fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => {
              searchTorrent(torrentName: searchController.text),
            },
            decoration: InputDecoration(
              hintText: 'Enter What You Want To Search',
              hintStyle: TextStyle(color: AppColors.searchBarPlaceholderColor),
              border: InputBorder.none,
            ),
          ),
        ),
        SizedBox(width: 12),
        // Search Button that blends into search bar widget
        GestureDetector(
          onTap: () {
            searchTorrent(torrentName: searchController.text);
          },
          child: Icon(Icons.search, color: AppColors.greenColor, size: 25),
        ),
        SizedBox(width: 20),
        // A clickable (X) icon to clear the text field.
        GestureDetector(
          onTap: () {
            searchController.clear();
          },
          child: Icon(Icons.clear, color: AppColors.brightRed, size: 25),
        ),
      ],
    ),
  );
}
