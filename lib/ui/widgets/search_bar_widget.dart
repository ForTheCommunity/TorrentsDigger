import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.searchController,
    required this.onSearchPressed,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.searchBarBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),

      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            "-> ",
            style: TextStyle(color: AppColors.greenColor, fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) {
                onSearchPressed();
              },
              decoration: InputDecoration(
                hintText: 'Search Anything',
                hintStyle: TextStyle(
                  color: AppColors.searchBarPlaceholderColor,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 12),
          // Search Button that blends into search bar widget
          GestureDetector(
            onTap: onSearchPressed,
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
}
