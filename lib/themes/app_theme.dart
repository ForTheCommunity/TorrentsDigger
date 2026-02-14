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
}
