import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/ui/widgets/popup_menu_button_widget.dart';

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
      ),

      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(
            "-> ",
            style: TextStyle(
              color: context.appColors.generalTextColor,
              fontSize: 20,
            ),
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
                hintText: 'Search Torrent',
                hintStyle: TextStyle(
                  color: context.appColors.searchBarPlaceholderColor,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 12),
          // Search Button that blends into search bar widget
          GestureDetector(
            onTap: onSearchPressed,
            child: Icon(
              Icons.search,
              color: context.appColors.generalTextColor,
              size: 25,
            ),
          ),
          SizedBox(width: 10),
          PopupMenuButtonWidget(),
        ],
      ),
    );
  }
}
