import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/routes/routes_name.dart';

class PopupMenuButtonWidget extends StatelessWidget {
  const PopupMenuButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: appColors.generalTextColor, size: 25),
      color: appColors.popupMenuBackgroundColor,
      onSelected: (value) {
        switch (value) {
          case 'bookmarks':
            Navigator.pushNamed(context, RoutesName.bookmarksScreen);
            break;
          case 'customs':
            Navigator.pushNamed(context, RoutesName.customsScreen);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'customs',
            child: Text(
              'Customs',
              style: TextStyle(
                color: appColors.popupMenuTextColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
          PopupMenuItem<String>(
            value: 'bookmarks',
            child: Text(
              'Bookmarks',
              style: TextStyle(
                color: appColors.popupMenuTextColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ];
      },
    );
  }
}
