import 'package:flutter/material.dart';
import 'package:torrents_digger/themes/app_theme.dart';

const String amoledThemeCode = "amoled";

class AmoledTheme extends AppTheme {
  @override
  String get themeName => "AMOLED";
  @override
  String get themeCode => amoledThemeCode;

  @override
  Color get scaffoldColor => Colors.black;
  @override
  Color get appBarBackgroundColor => Colors.black;
  @override
  Color get appBarTextColor => Colors.white;
  @override
  Color get appBarBackButtonIconColor => Colors.white;
  @override
  Color get scrollbarColor => const Color(0xFFFF9F0A);

  @override
  Color get generalTextColor => Colors.white;
  @override
  Color get settingsTextColor => Colors.white;
  @override
  Color get settingsIconsColor => const Color(0xFFFF9F0A);
  @override
  Color get settingsSwitchListTileActiveThumbColor => const Color(0xFFFF9F0A);
  @override
  Color get settingsSwitchListTileInactiveThumbColor => const Color(0xFF636366);
  @override
  Color get settingsSwitchListTileInactiveTrackColor => const Color(0xFF1C1C1E);

  @override
  Color get searchBarPlaceholderColor => const Color(0xFF8E8E93);
  @override
  Color get searchBarTextColor => Colors.white;
  @override
  Color get searchBarBackgroundColor => const Color(0xFF1C1C1E);

  @override
  Color get popupMenuBackgroundColor => const Color(0xFF1C1C1E);
  @override
  Color get popupMenuTextColor => Colors.white;

  @override
  Color get sourcesDropdownBackgroundColor => const Color(0xFF1C1C1E);
  @override
  Color get sourcesDropdownOpenedBackgroundColor => Colors.black;
  @override
  Color get dropdownArrowDownColor => const Color(0xFFFF9F0A);

  @override
  Color get sourceLabelColor => const Color(0xFF0A84FF);
  @override
  Color get categoryLabelColor => const Color(0xFFFF9F0A);
  @override
  Color get cardColor => const Color(0xFF141414);

  @override
  Color get cardPrimaryTextColor => Colors.white;
  @override
  Color get cardSecondaryTextColor => const Color(0xFF8E8E93);

  @override
  Color get leechersIconColor => const Color(0xFFFF453A);
  @override
  Color get leechersTextColor => const Color(0xFFFF453A);
  @override
  Color get seedersIconColor => const Color(0xFF30D158);
  @override
  Color get seedersTextColor => const Color(0xFF30D158);
  @override
  Color get creationDateIconColor => const Color(0xFF8E8E93);
  @override
  Color get creationDateTextColor => const Color(0xFF8E8E93);

  @override
  Color get magnetIconColor => const Color(0xFFBF5AF2);

  @override
  Color get bookmarkIconColor => const Color(0xFFFFD60A);
  @override
  Color get bookmarkedIconColor => const Color(0xFFFF9F0A);

  @override
  Color get sourceUrlAvailableColor => const Color(0xFF0A84FF);
  @override
  Color get sourceUrlUnAvailableColor => const Color(0xFF636366);

  @override
  Color get addTrackersListUrlTextFieldBackgroundColor =>
      const Color(0xFF1C1C1E);
  @override
  Color get addTrackersListUrlTextButtonTextColor => const Color(0xFFFF9F0A);
  @override
  Color get addTrackersListUrlTextButtonBorderColor => const Color(0xFFFF9F0A);

  @override
  Color get hyperlinkColor => const Color(0xFF0A84FF);
  @override
  Color get defaultTrackersInfoColor => Colors.white;
  @override
  Color get defaultTrackersTextColor => Colors.white;
  @override
  Color get defaultTrackersIconColor => Colors.white;
  @override
  Color get defaultTrackersInfoDialogBackgroundColor => const Color(0xFF141414);
  @override
  Color get defaultTrackersInfoDialogCloseTextColor => Colors.white;
  @override
  Color get defaultTrackersInfoDialogCloseTextButtonBackgroundColor =>
      const Color(0xFF2C2C2E);
  @override
  Color get defaultTrackersInfoIconColor => const Color(0xFFFF9F0A);
  @override
  Color get activeTrackersListIconColor => const Color(0xFFFF9F0A);

  @override
  Color get paginationCurrentTextColor => Colors.white;
  @override
  Color get paginationNextButtonBackgroundColor => const Color(0xFFFF9F0A);
  @override
  Color get paginationPreviousButtonBackgroundColor => const Color(0xFFFF9F0A);

  @override
  Color get textFormFieldInactiveColor => const Color(0xFF3A3A3C);
  @override
  Color get textFormFieldActiveColor => const Color(0xFFFF9F0A);

  @override
  Color get aboutDialogBackgroundColor => const Color(0xFF141414);
  @override
  Color get aboutDialogIconColor => const Color(0xFFFF9F0A);
  @override
  Color get aboutDialogHyperlinkTextColor => const Color(0xFF0A84FF);
  @override
  Color get aboutDialogTextColor => Colors.white;

  @override
  Color get settingsFloatingActionButtonForegroundColor =>
      const Color(0xFFFF9F0A);
  @override
  Color get settingsFloatingActionButtonBackgroundColor => Colors.transparent;
  @override
  Color get settingsFloatingActionButtonHoverBackgroundColor =>
      Colors.transparent;

  @override
  Color get circularProgressIndicatorColor => const Color(0xFFFF9F0A);

  @override
  Color get proxyDropdownBackgroundColor => const Color(0xFF1C1C1E);
  @override
  Color get proxyProtocolTextColor => Colors.white;
  @override
  Color get proxyProtocolArrowDropdownIconColor => Colors.white;
  @override
  Color get proxyIconColor => const Color(0xFF30D158);
  @override
  Color get proxyTextColor => Colors.white;
  @override
  Color get proxyDeleteIconColor => const Color(0xFFFF453A);
  @override
  Color get proxyFormFieldIconColor => const Color(0xFF30D158);
  @override
  Color get proxyFormFieldValidationErrorMessageColor =>
      const Color(0xFFFF453A);
  @override
  Color get proxySaveButtonBackgroundColor => const Color(0xFFFF9F0A);
  @override
  Color get proxySaveButtonTextColor => Colors.black;
  @override
  Color get proxySaveButtonBorderColor => const Color(0xFFFF9F0A);

  @override
  Color get activeThemeIconColor => const Color(0xFFFF9F0A);

  @override
  Color get contributeGetInvolvedIconColor => const Color(0xFFFF9F0A);
  @override
  Color get contributeSourceCodeIconColor => const Color(0xFFFF9F0A);
  @override
  Color get contributeSupportDevelopmentDonationIconColor => Colors.white;
  @override
  Color get contributeCryptoAddressBorderColor => const Color(0xFFFF9F0A);
  @override
  Color get contributeCardBackgroundColor => const Color(0xFF141414);
  @override
  Color get contributeCardShadowColor => const Color(0xFF2C2C2E);
  @override
  Color get contributeCryptoAddressTextColor => Colors.white;
  @override
  Color get contributeCryptoAddressBackgroundColor => Colors.black;
  @override
  Color get contributeCryptoAddressButtonBackgroundColor =>
      const Color.fromARGB(255, 49, 49, 49);

  @override
  Color get scrollToTopButtonBackgroundColor => const Color(0xFFFF9F0A);
  @override
  Color get scrollToTopButtonIconColor => Colors.black;

  @override
  Color get scaffoldMessengerMessageColor => Colors.white;
  @override
  Color get scaffoldMessengerBorderColor => const Color(0xFFFF9F0A);
  @override
  Color get scaffoldMessengerBackgroundColor => const Color(0xFF141414);

  @override
  Color get categoryChipBackgroundColor => const Color(0xFF1C1C1E);
  @override
  Color get categoryChipTextColor => const Color(0xFFD1D1D6);
  @override
  Color get categoryChipActiveTextColor => const Color(0xFFFF9F0A);
  @override
  Color get categoryChipBorderColor => const Color(0xFF2C2C2E);
  @override
  Color get categoryChipActiveBorderColor => const Color(0xFFFF9F0A);

  @override
  Color get newCategoryTextColor => const Color(0xFFFF9F0A);
  @override
  Color get newCategoryBackgroundColor => const Color(0xFF1C1C1E);
  @override
  Color get newCategoryBorderColor => const Color(0xFF2C2C2E);
  @override
  Color get createCategoryDialogBackgroundColor => const Color(0xFF141414);
  @override
  Color get bookmarkCategoryOptionPopupMenuBackgroundColor =>
      const Color(0xFF1C1C1E);
  @override
  Color get bookmarkCategoryOptionPopupMenuIconColor => Colors.white;
  @override
  Color get createNewCategoryDialogTextFieldHintColor =>
      const Color(0xFF8E8E93);
  @override
  Color get createNewCategoryDialogTextFieldInputTextColor => Colors.white;
  @override
  Color get createNewCategoryDialogTextFieldInputActiveBorderColor =>
      const Color(0xFFFF9F0A);
  @override
  Color get createNewCategoryDialogTextFieldInputInactiveBorderColor =>
      const Color(0xFF3A3A3C);
  @override
  Color get createNewCategoryDialogCreateButtonTextColor =>
      const Color(0xFF30D158);
  @override
  Color get createNewCategoryDialogCancelButtonTextColor =>
      const Color(0xFF8E8E93);
  @override
  Color get createNewCategoryDialogTitleTextColor => Colors.white;

  @override
  Color get bookmarkCategoryDialogBackgroundColor => const Color(0xFF141414);
  @override
  Color get bookmarkCategoryDialogTextColor => Colors.white;
  @override
  Color get bookmarkCategoryIconColor => const Color(0xFFFF9F0A);
  @override
  Color get bookmarkCategoryDialogCategoryTextColor => Colors.white;
  @override
  Color get bookmarkCategoryDialogCloseButtonBackgroundColor =>
      const Color(0xFF2C2C2E);
  @override
  Color get bookmarkCategoryDialogCloseButtonTextColor => Colors.white;
  @override
  Color get bookmarkCategoryDialogRemoveIconColor => const Color(0xFFFF453A);

  @override
  Brightness get statusBarIconBrightness => Brightness.light;
  @override
  Brightness get statusBarBrightness => Brightness.dark;

  @override
  Color get bookmarksStatsIconColor => const Color(0xFFFF9F0A);
  @override
  Color get bookmarksStatsBorderColor => const Color(0xFF2C2C2E);
  @override
  Color get bookmarksStatsColumnHeaderTextColor => const Color(0xFFFF9F0A);
  @override
  Color get bookmarksStatsTotalTextColor => const Color(0xFF30D158);
  @override
  Color get bookmarksStatsCategoryDataTextColor => Colors.white;

  @override
  Color get deleteCategoryConfirmationDialogTitleColor => Colors.white;
  @override
  Color get deleteCategoryConfirmationDialogTextColor => Colors.white;
  @override
  Color get deleteCategoryConfirmationDialogCodeColor =>
      const Color(0xFFFF453A);
  @override
  Color get deleteCategoryConfirmationDialogCodeBorderColor =>
      const Color(0xFFFF453A);
  @override
  Color get deleteCategoryConfirmationDialogInputTextfieldInactiveBorderColor =>
      const Color(0xFF3A3A3C);
  @override
  Color get deleteCategoryConfirmationDialogInputTextfieldActiveBorderColor =>
      const Color(0xFFFF9F0A);
  @override
  Color get deleteCategoryConfirmationDialogInputTextColor => Colors.white;
  @override
  Color get deleteCategoryConfirmationDialogCancelButtonTextColor =>
      const Color(0xFF8E8E93);
  @override
  Color get deleteCategoryConfirmationDialogCancelButtonBackgroundColor =>
      const Color(0xFF2C2C2E);
  @override
  Color get deleteCategoryConfirmationDialogDeleteButtonTextColor =>
      const Color(0xFFFF453A);
  @override
  Color get deleteCategoryConfirmationDialogCodeDoesnotMatchErrorTextColor =>
      const Color(0xFFFF453A);

  @override
  Color get searchBookmarksPlaceholderTextColor => const Color(0xFF8E8E93);
  @override
  Color get searchBookmarksIconColor => const Color(0xFFFF9F0A);
  @override
  Color get searchBookmarksClearIconColor => const Color(0xFFFF453A);

  @override
  Color get addTagIconColor => const Color(0xFFFF9F0A);
  @override
  Color get tagPickerDialogBackgroundColor => const Color(0xFF141414);
  @override
  Color get tagPickerDialogTitleColor => Colors.white;
  @override
  Color get tagPickerDialogTextColor => Colors.white;
  @override
  Color get tagPickerDialogCloseButtonBackgroundColor =>
      const Color(0xFF2C2C2E);
  @override
  Color get tagPickerDialogCloseButtonTextColor => Colors.white;
  @override
  Color get tagPickerDialogDoneButtonBackgroundColor => const Color(0xFFFF9F0A);
  @override
  Color get tagPickerDialogDoneButtonTextColor => Colors.black;
  @override
  Color get tagCheckboxActiveColor => const Color(0xFFFF9F0A);
  @override
  Color get tagCheckboxTickColor => Colors.black;

  @override
  Color get addTorrentManuallyFormTextFieldInActiveBorderColor =>
      const Color(0xFF3A3A3C);
  @override
  Color get addTorrentManuallyFormTextFieldActiveBorderColor =>
      const Color(0xFFFF9F0A);
  @override
  Color get addTorrentManuallyFormTextFieldLabelTextColor => Colors.white;
  @override
  Color get addTorrentManuallyFormTextFieldErrorMessageColor =>
      const Color(0xFFFF453A);
  @override
  Color get addTorrentManuallyFormSelectedCategoryBGColor =>
      const Color(0xFFFF9F0A);
  @override
  Color get addTorrentManuallyFormCheckmarkColor => Colors.black;
  @override
  Color get addTorrentManuallyFormSelectedCategoryNameTextColor => Colors.black;
  @override
  Color get addTorrentManuallyFormUnSelectedCategoryNameTextColor =>
      const Color(0xFF8E8E93);
  @override
  Color get addTorrentManuallyFormTagsNotCreatedYetMessageTextColor =>
      const Color(0xFF8E8E93);
  @override
  Color get addTorrentManuallyFormSelectedTagBGColor => const Color(0xFFFF9F0A);
  @override
  Color get addTorrentManuallyFormSelectedTagNameTextColor => Colors.black;
  @override
  Color get addTorrentManuallyFormUnSelectedTagNameTextColor =>
      const Color(0xFF8E8E93);
  @override
  Color get addTorrentManuallyFormAddTorrentButtonBackgroundColor =>
      const Color.fromARGB(255, 0, 0, 0);
  @override
  Color get addTorrentManuallyFormAddTorrentButtonBorderColor =>
      const Color.fromARGB(255, 135, 81, 0);
  @override
  Color get addTorrentManuallyFormAddTorrentButtonTextColor =>
      const Color.fromARGB(255, 247, 243, 243);
  @override
  Color get addTorrentManuallyFormExpandIconColor => Colors.white;
  @override
  Color get addTorrentManuallyFormCollapseIconColor => const Color(0xFFFF9F0A);
  @override
  Color get addTorrentManuallyFormInputTextColor => Colors.white;

  @override
  Color get torrentCardCopyButtonIconColor => const Color(0xFFFF9F0A);
  @override
  Color get torrentCardCopyMenuBackgroundColor => const Color(0xFF141414);
  @override
  Color get torrentCardCopyMenuTextColor => Colors.white;
  @override
  Color get torrentCardCopyMenuIconColor => const Color(0xFFFF9F0A);
  @override
  Color get torrentCardCopyMenuBorderColor => const Color(0xFF2C2C2E);
}
