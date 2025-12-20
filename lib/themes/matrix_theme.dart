import 'package:flutter/material.dart';
import 'package:torrents_digger/themes/app_theme.dart';

const String matrixThemeCode = "matrix";

class MatrixTheme extends AppTheme {
  @override
  String get themeName => "Matrix";
  @override
  String get themeCode => matrixThemeCode;

  @override
  Color get scaffoldColor => Color.fromRGBO(0, 0, 0, 1);
  @override
  Color get appBarBackgroundColor => Color.fromRGBO(0, 0, 0, 1);
  @override
  Color get appBarTextColor => Color.fromRGBO(0, 255, 0, 1);

  @override
  Color get generalTextColor => Color.fromRGBO(0, 255, 0, 1);
  @override
  Color get settingsTextColor => Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get settingsIconsColor => const Color.fromARGB(255, 255, 255, 255);

  @override
  Color get searchBarPlaceholderColor => Color.fromRGBO(238, 241, 82, 1);
  @override
  Color get searchBarTextColor => Color.fromARGB(236, 255, 255, 255);
  @override
  Color get searchBarBackgroundColor => Color.fromRGBO(17, 44, 39, 1);

  @override
  Color get popupMenuBackgroundColor => const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get popupMenuTextColor => const Color.fromARGB(255, 0, 255, 8);

  @override
  Color get sourcesDropdownBackgroundColor => Color.fromRGBO(9, 74, 11, 1);
  @override
  Color get categoriesDropdownBackgroundColor => Color.fromRGBO(9, 74, 11, 1);
  @override
  Color get sourcesDropdownOpenedBackgroundColor => Color.fromRGBO(1, 1, 1, 1);
  @override
  Color get categoriesDropdownOpenedBackgroundColor =>
      Color.fromRGBO(1, 1, 1, 1);

  @override
  Color get sourceLabelColor => Color.fromRGBO(0, 255, 247, 1);
  @override
  Color get categoryLabelColor => Color.fromRGBO(0, 255, 247, 1);
  @override
  Color get cardColor => Color.fromRGBO(33, 33, 33, 1);

  @override
  Color get cardPrimaryTextColor => Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get cardSecondaryTextColor => Color.fromRGBO(202, 188, 188, 1);

  @override
  Color get leechersIconColor => Color.fromRGBO(255, 0, 0, 1);
  @override
  Color get leechersTextColor => Color.fromRGBO(223, 33, 33, 1);
  @override
  Color get seedersIconColor => Color.fromRGBO(0, 255, 38, 1);
  @override
  Color get seedersTextColor => Color.fromRGBO(18, 204, 46, 1);
  @override
  Color get creationDateIconColor => Color.fromRGBO(18, 204, 46, 1);
  @override
  Color get creationDateTextColor => Color.fromRGBO(18, 204, 46, 1);

  @override
  Color get magnetBackgroundColor => Color.fromRGBO(0, 0, 0, 1);
  @override
  Color get magnetForegroundColor => Color.fromRGBO(0, 255, 132, 0.888);
  @override
  Color get magnetIconColor => Color.fromRGBO(0, 247, 255, 1);
  @override
  Color get magnetButtonSurfaceTintColor => Color.fromRGBO(247, 0, 255, 1);

  @override
  Color get bookmarkIconColor => Color.fromRGBO(135, 200, 189, 1);
  @override
  Color get bookmarkedIconColor => Color.fromRGBO(145, 255, 0, 1);

  @override
  Color get addTrackersListUrlTextFieldBackgroundColor =>
      Color.fromARGB(255, 40, 52, 54);
  @override
  Color get addTrackersListUrlTextButtonTextColor =>
      Color.fromARGB(255, 0, 255, 242);
  @override
  Color get addTrackersListUrlTextButtonBorderColor =>
      Color.fromARGB(255, 41, 55, 57);

  @override
  Color get hyperlinkColor => Color.fromRGBO(118, 131, 224, 1);
  @override
  Color get defaultTrackersInfoColor => Color.fromRGBO(255, 255, 255, 0.7);
  @override
  Color get defaultTrackersTextColor =>
      const Color.fromARGB(255, 255, 255, 255);
  @override
  Color get defaultTrackersIconColor =>
      const Color.fromARGB(255, 255, 255, 255);
  @override
  @override
  Color get activeTrackersListIconColor => Color.fromRGBO(0, 255, 0, 1);

  @override
  Color get textFormFieldInactiveColor => Color.fromRGBO(69, 130, 127, 1);
  @override
  Color get textFormFieldActiveColor => Color.fromRGBO(0, 255, 0, 1);

  @override
  Color get aboutDialogIconColor => Color.fromRGBO(0, 255, 47, 1);
  @override
  Color get aboutDialogTextColor => Color.fromRGBO(82, 239, 245, 1);

  @override
  Color get settingsFloatingActionButtonForegroundColor =>
      Color.fromRGBO(0, 255, 0, 1);
  @override
  Color get settingsFloatingActionButtonBackgroundColor => Colors.transparent;
  @override
  Color get settingsFloatingActionButtonHoverBackgroundColor =>
      Colors.transparent;

  @override
  Color get circularProgressIndicatorColor => Color.fromRGBO(0, 255, 0, 1);

  @override
  Color get proxyDropdownBackgroundColor => Color.fromRGBO(9, 74, 11, 1);
  @override
  Color get proxyProtocolTextColor => Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get proxyProtocolArrowDropdownIconColor =>
      Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get proxyIconColor => Color.fromRGBO(0, 255, 0, 1);
  @override
  Color get proxyTextColor => Color.fromRGBO(0, 255, 0, 1);
  @override
  Color get proxyDeleteIconColor => Color.fromRGBO(255, 0, 0, 1);
  @override
  Color get proxyFormFieldIconColor => const Color.fromARGB(255, 255, 255, 255);
  @override
  Color get proxyFormFieldValidationErrorMessageColor =>
      const Color.fromARGB(255, 255, 17, 0);
  @override
  Color get proxySaveButtonBackgroundColor =>
      const Color.fromARGB(255, 3, 21, 19);
  @override
  Color get proxySaveButtonTextColor => const Color.fromARGB(255, 4, 255, 0);
  @override
  Color get proxySaveButtonBorderColor =>
      const Color.fromARGB(255, 152, 173, 153);

  @override
  Color get activeThemeIconColor => const Color.fromARGB(255, 0, 255, 8);

  // @override
  // Color get scaffoldMessengerMessageColor => Color.fromRGBO(255, 255, 255, 1);
  // @override
  // Color get scaffoldMessengerBorderColor => Color.fromRGBO(0, 255, 0, 1);
  // @override
  // Color get scaffoldMessengerBackgroundColor => Color.fromRGBO(0, 0, 0, 1);
}
