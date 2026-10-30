import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/extensions.dart';

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
        color: context.appColors.searchBarBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.appColors.generalTextColor.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 4.0,
        top: 2.0,
        bottom: 2.0,
      ),
      child: Row(
        children: [
          Text(
            "-> ",
            style: TextStyle(
              color: context.appColors.generalTextColor,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              style: TextStyle(color: context.appColors.searchBarTextColor),
              onSubmitted: (_) {
                onSearchPressed();
              },
              decoration: InputDecoration(
                hintText: 'Search Torrent',
                hintStyle: TextStyle(
                  color: context.appColors.searchBarPlaceholderColor,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Search Button with generous touch target & ripple feedback
          IconButton(
            onPressed: onSearchPressed,
            tooltip: 'Search',
            icon: Icon(
              Icons.search,
              color: context.appColors.generalTextColor,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
