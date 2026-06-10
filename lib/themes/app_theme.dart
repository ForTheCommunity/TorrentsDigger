import 'package:flutter/material.dart';

abstract class AppTheme {
  String get themeName;
  String get themeCode;

  Color get scaffoldColor;
  Color get appBarBackgroundColor;
  Color get appBarTextColor;
  Color get scrollbarColor;

  Color get generalTextColor;
  Color get settingsTextColor;
  Color get settingsIconsColor;
  Color get settingsSwitchListTileActiveThumbColor;
  Color get settingsSwitchListTileInactiveThumbColor;
  Color get settingsSwitchListTileInactiveTrackColor;

  Color get searchBarPlaceholderColor;
  Color get searchBarTextColor;
  Color get searchBarBackgroundColor;

  Color get popupMenuBackgroundColor;
  Color get popupMenuTextColor;

  Color get sourcesDropdownBackgroundColor;
  // Color get categoriesDropdownBackgroundColor;
  Color get sourcesDropdownOpenedBackgroundColor;
  Color get dropdownArrowDownColor;
  // Color get categoriesDropdownOpenedBackgroundColor;

  Color get sourceLabelColor;
  Color get categoryLabelColor;
  Color get cardColor;

  Color get cardPrimaryTextColor;
  Color get cardSecondaryTextColor;

  Color get leechersIconColor;
  Color get leechersTextColor;
  Color get seedersIconColor;
  Color get seedersTextColor;
  Color get creationDateIconColor;
  Color get creationDateTextColor;

  Color get magnetIconColor;

  Color get bookmarkIconColor;
  Color get bookmarkedIconColor;

  Color get sourceUrlAvailableColor;
  Color get sourceUrlUnAvailableColor;

  Color get addTrackersListUrlTextFieldBackgroundColor;
  Color get addTrackersListUrlTextButtonTextColor;
  Color get addTrackersListUrlTextButtonBorderColor;

  Color get hyperlinkColor;
  Color get defaultTrackersInfoColor;
  Color get defaultTrackersTextColor;
  Color get defaultTrackersIconColor;
  Color get defaultTrackersInfoDialogBackgroundColor;
  Color get defaultTrackersInfoDialogCloseTextColor;
  Color get defaultTrackersInfoDialogCloseTextButtonBackgroundColor;
  Color get defaultTrackersInfoIconColor;
  Color get activeTrackersListIconColor;

  Color get paginationCurrentTextColor;
  Color get paginationNextButtonBackgroundColor;
  Color get paginationPreviousButtonBackgroundColor;

  Color get textFormFieldInactiveColor;
  Color get textFormFieldActiveColor;

  Color get aboutDialogBackgroundColor;
  Color get aboutDialogIconColor;
  Color get aboutDialogHyperlinkTextColor;
  Color get aboutDialogTextColor;

  Color get settingsFloatingActionButtonForegroundColor;
  Color get settingsFloatingActionButtonBackgroundColor;
  Color get settingsFloatingActionButtonHoverBackgroundColor;

  Color get circularProgressIndicatorColor;

  Color get proxyDropdownBackgroundColor;
  Color get proxyProtocolTextColor;
  Color get proxyIconColor;
  Color get proxyTextColor;
  Color get proxyProtocolArrowDropdownIconColor;
  Color get proxyDeleteIconColor;
  Color get proxyFormFieldIconColor;
  Color get proxyFormFieldValidationErrorMessageColor;
  Color get proxySaveButtonBackgroundColor;
  Color get proxySaveButtonTextColor;
  Color get proxySaveButtonBorderColor;

  Color get activeThemeIconColor;

  Color get contributeGetInvolvedIconColor;
  Color get contributeSourceCodeIconColor;
  Color get contributeSupportDevelopmentDonationIconColor;
  Color get contributeCryptoAddressBorderColor;
  Color get contributeCardBackgroundColor;
  Color get contributeCardShadowColor;
  Color get contributeCryptoAddressTextColor;
  Color get contributeCryptoAddressBackgroundColor;
  Color get contributeCryptoAddressButtonBackgroundColor;

  Color get scrollToTopButtonBackgroundColor;
  Color get scrollToTopButtonIconColor;

  Color get scaffoldMessengerMessageColor;
  Color get scaffoldMessengerBorderColor;
  Color get scaffoldMessengerBackgroundColor;

  Color get categoryChipBackgroundColor;
  Color get categoryChipTextColor;
  Color get categoryChipActiveTextColor;
  Color get categoryChipBorderColor;
  Color get categoryChipActiveBorderColor;

  Color get newCategoryTextColor;
  Color get newCategoryBackgroundColor;
  Color get newCategoryBorderColor;
  Color get createCategoryDialogBackgroundColor;
  Color get bookmarkCategoryOptionPopupMenuBackgroundColor;
  Color get bookmarkCategoryOptionPopupMenuIconColor;
  Color get createNewCategoryDialogTextFieldHintColor;
  Color get createNewCategoryDialogTextFieldInputTextColor;
  Color get createNewCategoryDialogTextFieldInputActiveBorderColor;
  Color get createNewCategoryDialogTextFieldInputInactiveBorderColor;
  Color get createNewCategoryDialogCreateButtonTextColor;
  Color get createNewCategoryDialogCancelButtonTextColor;
  Color get createNewCategoryDialogTitleTextColor;

  Color get bookmarkCategoryDialogBackgroundColor;
  Color get bookmarkCategoryDialogTextColor;
  Color get bookmarkCategoryIconColor;
  Color get bookmarkCategoryDialogCategoryTextColor;
  // Color get bookmarkCategoryDialogCloseButtonBackgroundColor;
  Color get bookmarkCategoryDialogCloseButtonTextColor;
  Color get bookmarkCategoryDialogRemoveIconColor;

  Brightness get statusBarIconBrightness;
  Brightness get statusBarBrightness;

  Color get bookmarksStatsIconColor;
  Color get bookmarksStatsBorderColor;
  Color get bookmarksStatsColumnHeaderTextColor;
  Color get bookmarksStatsTotalTextColor;
  Color get bookmarksStatsCategoryDataTextColor;

  Color get deleteCategoryConfirmationDialogTitleColor;
  Color get deleteCategoryConfirmationDialogTextColor;
  Color get deleteCategoryConfirmationDialogCodeColor;
  Color get deleteCategoryConfirmationDialogCodeBorderColor;
  Color get deleteCategoryConfirmationDialogInputTextfieldInactiveBorderColor;
  Color get deleteCategoryConfirmationDialogInputTextfieldActiveBorderColor;
  Color get deleteCategoryConfirmationDialogInputTextColor;
  Color get deleteCategoryConfirmationDialogCancelButtonTextColor;
  Color get deleteCategoryConfirmationDialogDeleteButtonTextColor;
  Color get deleteCategoryConfirmationDialogCodeDoesnotMatchErrorTextColor;
}
