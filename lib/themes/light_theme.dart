import 'package:flutter/material.dart';
import 'package:torrents_digger/themes/app_theme.dart';

const String lightThemeCode = "light";

class LightTheme extends AppTheme {
  @override
  String get themeName => "Light";
  @override
  String get themeCode => lightThemeCode;

  @override
  Color get scaffoldColor => Colors.white;
  @override
  Color get appBarBackgroundColor => const Color.fromARGB(255, 83, 100, 99);
  @override
  Color get appBarTextColor => Colors.white;
  @override
  Color get appBarBackButtonIconColor => Colors.white;
  @override
  Color get scrollbarColor => const Color.fromARGB(255, 1, 173, 170);

  @override
  Color get generalTextColor => Colors.black;
  @override
  Color get settingsTextColor => Colors.black;
  @override
  Color get settingsIconsColor => const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get settingsSwitchListTileActiveThumbColor =>
      const Color.fromARGB(255, 137, 0, 132);
  @override
  Color get settingsSwitchListTileInactiveThumbColor =>
      const Color.fromARGB(255, 255, 69, 249);
  @override
  Color get settingsSwitchListTileInactiveTrackColor =>
      const Color.fromARGB(255, 255, 255, 255);

  @override
  Color get searchBarPlaceholderColor => const Color.fromARGB(255, 20, 19, 19);
  @override
  Color get searchBarTextColor => const Color.fromARGB(235, 0, 0, 0);
  @override
  Color get searchBarBackgroundColor =>
      const Color.fromARGB(237, 196, 236, 203);

  @override
  Color get popupMenuBackgroundColor =>
      const Color.fromARGB(237, 196, 236, 203);
  @override
  Color get popupMenuTextColor => Colors.black;

  @override
  Color get sourcesDropdownBackgroundColor =>
      const Color.fromARGB(255, 164, 241, 223);
  @override
  Color get sourcesDropdownOpenedBackgroundColor => Colors.grey[100]!;
  @override
  Color get dropdownArrowDownColor => const Color.fromARGB(255, 0, 0, 0);

  @override
  Color get sourceLabelColor => Colors.blue;
  @override
  Color get categoryLabelColor => Colors.blue;
  @override
  Color get cardColor => const Color.fromARGB(255, 210, 214, 246);

  @override
  Color get cardPrimaryTextColor => Colors.black;
  @override
  Color get cardSecondaryTextColor => const Color.fromARGB(255, 28, 38, 28);

  @override
  Color get leechersIconColor => const Color.fromARGB(255, 255, 17, 0);
  @override
  Color get leechersTextColor => const Color.fromARGB(255, 255, 17, 0);
  @override
  Color get seedersIconColor => const Color.fromARGB(255, 2, 170, 7);
  @override
  Color get seedersTextColor => const Color.fromARGB(255, 2, 157, 7);
  @override
  Color get creationDateIconColor => Colors.blueGrey;
  @override
  Color get creationDateTextColor => Colors.blueGrey;

  @override
  Color get magnetIconColor => const Color.fromARGB(255, 234, 0, 255);

  @override
  Color get bookmarkIconColor => const Color.fromARGB(255, 1, 134, 121);
  @override
  Color get bookmarkedIconColor => const Color.fromARGB(255, 3, 80, 70);

  @override
  Color get sourceUrlAvailableColor => const Color.fromARGB(255, 0, 21, 255);
  @override
  Color get sourceUrlUnAvailableColor => const Color.fromARGB(255, 37, 37, 37);

  @override
  Color get addTrackersListUrlTextFieldBackgroundColor => Colors.grey[200]!;
  @override
  Color get addTrackersListUrlTextButtonTextColor => Colors.blue;
  @override
  Color get addTrackersListUrlTextButtonBorderColor => Colors.blue;

  @override
  Color get hyperlinkColor => Colors.blue;
  @override
  Color get defaultTrackersInfoColor => const Color.fromARGB(255, 25, 0, 0);
  @override
  Color get defaultTrackersTextColor => const Color.fromARGB(255, 25, 0, 0);
  @override
  Color get defaultTrackersIconColor => const Color.fromARGB(255, 25, 0, 0);
  @override
  Color get defaultTrackersInfoDialogBackgroundColor =>
      const Color.fromARGB(255, 255, 255, 255);
  @override
  Color get defaultTrackersInfoDialogCloseTextColor =>
      const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get defaultTrackersInfoDialogCloseTextButtonBackgroundColor =>
      const Color.fromARGB(255, 242, 176, 168);
  @override
  Color get defaultTrackersInfoIconColor =>
      const Color.fromARGB(255, 255, 255, 255);
  @override
  Color get activeTrackersListIconColor =>
      const Color.fromARGB(255, 26, 192, 181);

  @override
  Color get paginationCurrentTextColor => const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get paginationNextButtonBackgroundColor =>
      const Color.fromARGB(255, 0, 106, 255);
  @override
  Color get paginationPreviousButtonBackgroundColor =>
      const Color.fromARGB(255, 0, 106, 255);

  @override
  Color get textFormFieldInactiveColor => Colors.grey;
  @override
  Color get textFormFieldActiveColor =>
      const Color.fromARGB(255, 227, 137, 241);

  @override
  Color get aboutDialogBackgroundColor => Colors.white;
  @override
  Color get aboutDialogIconColor => Colors.black;
  @override
  Color get aboutDialogHyperlinkTextColor =>
      const Color.fromARGB(255, 0, 87, 158);
  @override
  Color get aboutDialogTextColor => Colors.black;

  @override
  Color get settingsFloatingActionButtonForegroundColor =>
      const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get settingsFloatingActionButtonBackgroundColor =>
      const Color.fromARGB(255, 255, 255, 255);
  @override
  Color get settingsFloatingActionButtonHoverBackgroundColor =>
      const Color.fromARGB(255, 255, 255, 255);

  @override
  Color get circularProgressIndicatorColor => Colors.blue;

  @override
  Color get proxyDropdownBackgroundColor =>
      const Color.fromARGB(255, 236, 201, 236);
  @override
  Color get proxyProtocolTextColor => Color.fromRGBO(0, 0, 0, 1);
  @override
  Color get proxyProtocolArrowDropdownIconColor => Colors.black;
  @override
  Color get proxyIconColor => Colors.green;
  @override
  Color get proxyTextColor => const Color.fromARGB(255, 65, 1, 45);
  @override
  Color get proxyDeleteIconColor => Colors.red;
  @override
  Color get proxyFormFieldIconColor => const Color.fromARGB(255, 0, 194, 32);
  @override
  Color get proxyFormFieldValidationErrorMessageColor =>
      const Color.fromARGB(255, 255, 17, 0);
  @override
  Color get proxySaveButtonBackgroundColor =>
      const Color.fromARGB(255, 255, 255, 255);
  @override
  Color get proxySaveButtonTextColor => const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get proxySaveButtonBorderColor =>
      const Color.fromARGB(255, 232, 178, 233);

  @override
  Color get activeThemeIconColor => const Color.fromARGB(255, 208, 0, 184);

  @override
  Color get contributeGetInvolvedIconColor =>
      const Color.fromARGB(255, 216, 27, 27);
  @override
  Color get contributeSourceCodeIconColor => const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get contributeSupportDevelopmentDonationIconColor =>
      const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get contributeCryptoAddressBorderColor =>
      const Color.fromARGB(255, 255, 0, 251);
  @override
  Color get contributeCardBackgroundColor =>
      const Color.fromARGB(255, 193, 232, 228);
  @override
  Color get contributeCardShadowColor => const Color.fromARGB(255, 255, 0, 225);
  @override
  Color get contributeCryptoAddressTextColor =>
      const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get contributeCryptoAddressBackgroundColor =>
      const Color.fromARGB(255, 255, 255, 255);
  @override
  Color get contributeCryptoAddressButtonBackgroundColor =>
      const Color.fromARGB(255, 255, 255, 255);

  @override
  Color get scrollToTopButtonBackgroundColor =>
      const Color.fromARGB(212, 255, 255, 255);
  @override
  Color get scrollToTopButtonIconColor =>
      const Color.fromARGB(255, 226, 27, 173);

  @override
  Color get scaffoldMessengerMessageColor => const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get scaffoldMessengerBorderColor => const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get scaffoldMessengerBackgroundColor =>
      const Color.fromARGB(255, 255, 255, 255);

  @override
  Color get categoryChipBackgroundColor => Color.fromRGBO(224, 220, 220, 1);
  @override
  Color get categoryChipTextColor => Color.fromRGBO(0, 0, 0, 1);
  @override
  Color get categoryChipActiveTextColor => Color.fromRGBO(30, 50, 203, 1);
  @override
  Color get categoryChipBorderColor => Color.fromRGBO(44, 121, 160, 1);
  @override
  Color get categoryChipActiveBorderColor => Color.fromRGBO(241, 24, 238, 1);

  @override
  Color get newCategoryTextColor => Color.fromRGBO(222, 40, 197, 1);
  @override
  Color get newCategoryBackgroundColor => Color.fromRGBO(231, 225, 225, 1);
  @override
  Color get newCategoryBorderColor => Color.fromRGBO(0, 0, 0, 1);
  @override
  Color get createCategoryDialogBackgroundColor =>
      Color.fromRGBO(15, 15, 15, 0.867);
  @override
  Color get bookmarkCategoryOptionPopupMenuBackgroundColor =>
      Color.fromRGBO(0, 28, 49, 1);
  @override
  Color get bookmarkCategoryOptionPopupMenuIconColor =>
      Color.fromRGBO(0, 0, 0, 1);
  @override
  Color get createNewCategoryDialogTextFieldHintColor =>
      Color.fromRGBO(227, 221, 38, 1);
  @override
  Color get createNewCategoryDialogTextFieldInputTextColor =>
      Color.fromRGBO(0, 255, 234, 1);
  @override
  Color get createNewCategoryDialogTextFieldInputActiveBorderColor =>
      Color.fromRGBO(154, 144, 144, 1);
  @override
  Color get createNewCategoryDialogTextFieldInputInactiveBorderColor =>
      Color.fromRGBO(11, 225, 225, 1);
  @override
  Color get createNewCategoryDialogCreateButtonTextColor =>
      Color.fromRGBO(14, 246, 45, 1);
  @override
  Color get createNewCategoryDialogCancelButtonTextColor =>
      Color.fromRGBO(11, 225, 225, 1);
  @override
  Color get createNewCategoryDialogTitleTextColor =>
      Color.fromRGBO(255, 255, 255, 1);

  @override
  Color get bookmarkCategoryDialogBackgroundColor =>
      Color.fromRGBO(39, 39, 39, 1);
  @override
  Color get bookmarkCategoryDialogTextColor => Color.fromRGBO(251, 251, 251, 1);
  @override
  Color get bookmarkCategoryIconColor => Color.fromRGBO(0, 217, 255, 1);
  @override
  Color get bookmarkCategoryDialogCategoryTextColor =>
      Color.fromRGBO(1, 1, 1, 1);
  @override
  Color get bookmarkCategoryDialogCloseButtonBackgroundColor =>
      Color.fromRGBO(75, 71, 71, 1);
  @override
  Color get bookmarkCategoryDialogCloseButtonTextColor =>
      Color.fromRGBO(241, 234, 234, 1);
  @override
  Color get bookmarkCategoryDialogRemoveIconColor =>
      Color.fromRGBO(247, 11, 11, 1);

  @override
  Brightness get statusBarIconBrightness => Brightness.dark;
  @override
  Brightness get statusBarBrightness => Brightness.light;

  @override
  Color get bookmarksStatsIconColor => Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get bookmarksStatsBorderColor => Color.fromRGBO(0, 0, 0, 0.245);
  @override
  Color get bookmarksStatsColumnHeaderTextColor =>
      Color.fromRGBO(0, 17, 126, 1);
  @override
  Color get bookmarksStatsTotalTextColor => Color.fromRGBO(255, 0, 102, 1);
  @override
  Color get bookmarksStatsCategoryDataTextColor => Color.fromRGBO(0, 0, 0, 1);

  @override
  Color get deleteCategoryConfirmationDialogTitleColor =>
      Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get deleteCategoryConfirmationDialogTextColor =>
      Color.fromRGBO(255, 255, 255, 1);
  @override
  Color get deleteCategoryConfirmationDialogCodeColor =>
      Color.fromRGBO(255, 0, 0, 1);
  @override
  Color get deleteCategoryConfirmationDialogCodeBorderColor =>
      Color.fromRGBO(255, 0, 0, 1);
  @override
  Color get deleteCategoryConfirmationDialogInputTextfieldInactiveBorderColor =>
      Color.fromRGBO(193, 176, 176, 1);
  @override
  Color get deleteCategoryConfirmationDialogInputTextfieldActiveBorderColor =>
      Color.fromRGBO(116, 193, 183, 1);
  @override
  Color get deleteCategoryConfirmationDialogInputTextColor =>
      Color.fromRGBO(255, 0, 0, 1);
  @override
  Color get deleteCategoryConfirmationDialogCancelButtonTextColor =>
      Color.fromRGBO(0, 255, 217, 1);
  @override
  Color get deleteCategoryConfirmationDialogCancelButtonBackgroundColor =>
      Colors.black;
  @override
  Color get deleteCategoryConfirmationDialogDeleteButtonTextColor =>
      Color.fromARGB(223, 0, 255, 221);
  @override
  Color get deleteCategoryConfirmationDialogCodeDoesnotMatchErrorTextColor =>
      Color.fromRGBO(0, 221, 255, 1);

  @override
  Color get searchBookmarksPlaceholderTextColor =>
      const Color.fromARGB(255, 255, 255, 255);
  @override
  Color get searchBookmarksIconColor => const Color.fromARGB(255, 249, 224, 255);
  @override
  Color get searchBookmarksClearIconColor =>
      const Color.fromARGB(255, 126, 246, 255);
}
