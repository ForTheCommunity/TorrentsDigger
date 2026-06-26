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
  Color get appBarBackButtonIconColor => const Color.fromARGB(255, 218, 208, 208);
  @override
  Color get scrollbarColor => const Color.fromARGB(255, 17, 255, 0);

  @override
  Color get generalTextColor => Color.fromRGBO(0, 255, 0, 1);
  @override
  Color get settingsTextColor => Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get settingsIconsColor => const Color.fromARGB(255, 255, 255, 255);
  @override
  Color get settingsSwitchListTileActiveThumbColor =>
      const Color.fromARGB(255, 0, 255, 4);
  @override
  Color get settingsSwitchListTileInactiveThumbColor =>
      const Color.fromARGB(255, 111, 226, 209);
  @override
  Color get settingsSwitchListTileInactiveTrackColor =>
      const Color.fromARGB(255, 34, 34, 34);

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
  Color get sourcesDropdownOpenedBackgroundColor => Color.fromRGBO(1, 1, 1, 1);
  @override
  Color get dropdownArrowDownColor => Color.fromRGBO(17, 255, 0, 1);

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
  Color get magnetIconColor => Color.fromRGBO(9, 255, 0, 1);

  @override
  Color get bookmarkIconColor => Color.fromRGBO(135, 200, 189, 1);
  @override
  Color get bookmarkedIconColor => Color.fromRGBO(145, 255, 0, 1);

  @override
  Color get sourceUrlAvailableColor => const Color.fromARGB(255, 96, 190, 181);
  @override
  Color get sourceUrlUnAvailableColor =>
      const Color.fromARGB(255, 138, 129, 129);

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
  Color get defaultTrackersInfoDialogBackgroundColor =>
      const Color.fromARGB(255, 16, 17, 17);
  @override
  Color get defaultTrackersInfoDialogCloseTextColor =>
      const Color.fromARGB(255, 26, 255, 0);
  @override
  Color get defaultTrackersInfoDialogCloseTextButtonBackgroundColor =>
      const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get defaultTrackersInfoIconColor =>
      const Color.fromARGB(255, 25, 223, 15);
  @override
  Color get activeTrackersListIconColor => Color.fromRGBO(0, 255, 0, 1);

  @override
  Color get paginationCurrentTextColor =>
      const Color.fromARGB(226, 255, 255, 255);
  @override
  Color get paginationNextButtonBackgroundColor =>
      const Color.fromARGB(255, 34, 255, 0);
  @override
  Color get paginationPreviousButtonBackgroundColor =>
      const Color.fromARGB(255, 34, 255, 0);

  @override
  Color get textFormFieldInactiveColor => Color.fromRGBO(69, 130, 127, 1);
  @override
  Color get textFormFieldActiveColor => Color.fromRGBO(91, 181, 87, 1);

  @override
  Color get aboutDialogBackgroundColor => const Color.fromARGB(255, 20, 20, 20);
  @override
  Color get aboutDialogIconColor => Color.fromRGBO(0, 255, 47, 1);
  @override
  Color get aboutDialogHyperlinkTextColor => Color.fromRGBO(82, 239, 245, 1);
  @override
  Color get aboutDialogTextColor => const Color.fromARGB(255, 239, 237, 237);

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

  @override
  Color get contributeGetInvolvedIconColor =>
      const Color.fromARGB(255, 255, 255, 255);
  @override
  Color get contributeSourceCodeIconColor =>
      const Color.fromARGB(255, 17, 255, 0);
  @override
  Color get contributeSupportDevelopmentDonationIconColor =>
      const Color.fromARGB(255, 0, 255, 21);
  @override
  Color get contributeCryptoAddressBorderColor =>
      const Color.fromARGB(255, 21, 255, 0);
  @override
  Color get contributeCardBackgroundColor =>
      const Color.fromARGB(255, 19, 18, 18);
  @override
  Color get contributeCardShadowColor => const Color.fromARGB(255, 37, 247, 62);
  @override
  Color get contributeCryptoAddressTextColor =>
      const Color.fromARGB(239, 4, 255, 0);
  @override
  Color get contributeCryptoAddressBackgroundColor =>
      const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get contributeCryptoAddressButtonBackgroundColor =>
      const Color.fromARGB(255, 28, 27, 27);

  @override
  Color get scrollToTopButtonBackgroundColor =>
      const Color.fromARGB(1, 1, 1, 1);
  @override
  Color get scrollToTopButtonIconColor => const Color.fromARGB(255, 0, 255, 0);

  @override
  Color get scaffoldMessengerMessageColor => Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get scaffoldMessengerBorderColor => Color.fromRGBO(0, 255, 0, 1);
  @override
  Color get scaffoldMessengerBackgroundColor => Color.fromRGBO(0, 0, 0, 1);

  @override
  Color get categoryChipBackgroundColor => Color.fromRGBO(0, 0, 0, 1);
  @override
  Color get categoryChipTextColor => Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get categoryChipActiveTextColor => Color.fromRGBO(4, 239, 4, 1);
  @override
  Color get categoryChipBorderColor => Color.fromRGBO(91, 90, 90, 1);
  @override
  Color get categoryChipActiveBorderColor => Color.fromRGBO(14, 188, 17, 1);

  @override
  Color get newCategoryTextColor => Color.fromRGBO(191, 197, 191, 1);
  @override
  Color get newCategoryBackgroundColor => Color.fromRGBO(0, 0, 0, 1);
  @override
  Color get newCategoryBorderColor => Color.fromRGBO(2, 98, 19, 1);
  @override
  Color get createCategoryDialogBackgroundColor =>
      Color.fromRGBO(12, 12, 12, 1);
  @override
  Color get bookmarkCategoryOptionPopupMenuBackgroundColor =>
      Color.fromRGBO(1, 1, 1, 1);
  @override
  Color get bookmarkCategoryOptionPopupMenuIconColor =>
      Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get createNewCategoryDialogTextFieldHintColor =>
      Color.fromRGBO(199, 188, 188, 1);
  @override
  Color get createNewCategoryDialogTextFieldInputTextColor =>
      Color.fromRGBO(30, 213, 55, 1);
  @override
  Color get createNewCategoryDialogTextFieldInputActiveBorderColor =>
      Color.fromRGBO(5, 114, 120, 1);
  @override
  Color get createNewCategoryDialogTextFieldInputInactiveBorderColor =>
      Color.fromRGBO(133, 10, 131, 1);
  @override
  Color get createNewCategoryDialogCreateButtonTextColor =>
      Color.fromRGBO(0, 255, 34, 1);
  @override
  Color get createNewCategoryDialogCancelButtonTextColor =>
      Color.fromRGBO(127, 223, 233, 1);
  @override
  Color get createNewCategoryDialogTitleTextColor =>
      Color.fromRGBO(0, 255, 30, 1);

  @override
  Color get bookmarkCategoryDialogBackgroundColor =>
      Color.fromRGBO(1, 1, 1, 0.933);
  @override
  Color get bookmarkCategoryDialogTextColor => Color.fromRGBO(228, 222, 222, 1);
  @override
  Color get bookmarkCategoryIconColor => Color.fromRGBO(27, 223, 9, 1);
  @override
  Color get bookmarkCategoryDialogCategoryTextColor =>
      Color.fromRGBO(1, 1, 1, 1);
  @override
  Color get bookmarkCategoryDialogCloseButtonBackgroundColor =>
      Color.fromRGBO(22, 22, 22, 1);
  @override
  Color get bookmarkCategoryDialogCloseButtonTextColor =>
      Color.fromRGBO(46, 235, 200, 1);
  @override
  Color get bookmarkCategoryDialogRemoveIconColor =>
      Color.fromRGBO(255, 0, 0, 1);

  @override
  Brightness get statusBarIconBrightness => Brightness.light;
  @override
  Brightness get statusBarBrightness => Brightness.dark;

  @override
  Color get bookmarksStatsIconColor => Color.fromRGBO(0, 255, 4, 1);
  @override
  Color get bookmarksStatsBorderColor => Color.fromRGBO(76, 76, 77, 1);
  @override
  Color get bookmarksStatsColumnHeaderTextColor =>
      Color.fromRGBO(38, 255, 0, 1);
  @override
  Color get bookmarksStatsTotalTextColor => Color.fromRGBO(38, 255, 0, 1);
  @override
  Color get bookmarksStatsCategoryDataTextColor =>
      Color.fromRGBO(255, 255, 255, 0.94);

  @override
  Color get deleteCategoryConfirmationDialogTitleColor =>
      Color.fromRGBO(38, 255, 0, 1);
  @override
  Color get deleteCategoryConfirmationDialogTextColor =>
      Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get deleteCategoryConfirmationDialogCodeColor =>
      Color.fromRGBO(255, 0, 0, 1);
  @override
  Color get deleteCategoryConfirmationDialogCodeBorderColor =>
      Color.fromRGBO(145, 143, 143, 1);
  @override
  Color get deleteCategoryConfirmationDialogInputTextfieldInactiveBorderColor =>
      Color.fromRGBO(117, 115, 115, 1);
  @override
  Color get deleteCategoryConfirmationDialogInputTextfieldActiveBorderColor =>
      Color.fromRGBO(135, 255, 102, 1);
  @override
  Color get deleteCategoryConfirmationDialogInputTextColor =>
      Color.fromRGBO(255, 0, 0, 1);
  @override
  Color get deleteCategoryConfirmationDialogCancelButtonTextColor =>
      Color.fromRGBO(0, 255, 225, 1);
  @override
  Color get deleteCategoryConfirmationDialogCancelButtonBackgroundColor =>
      Colors.black;
  @override
  Color get deleteCategoryConfirmationDialogDeleteButtonTextColor =>
      Color.fromRGBO(255, 0, 0, 1);
  @override
  Color get deleteCategoryConfirmationDialogCodeDoesnotMatchErrorTextColor =>
      Color.fromRGBO(255, 0, 0, 1);

  @override
  Color get searchBookmarksPlaceholderTextColor =>
      const Color.fromARGB(255, 77, 255, 77);
  @override
  Color get searchBookmarksIconColor => const Color.fromARGB(255, 0, 255, 42);
  @override
  Color get searchBookmarksClearIconColor =>
      const Color.fromARGB(255, 117, 255, 133);
}
