import 'package:flutter/material.dart';
import 'package:torrents_digger/themes/app_theme.dart';

const String darkThemeCode = "dark";

class DarkTheme extends AppTheme {
  @override
  String get themeName => "Dark";
  @override
  String get themeCode => darkThemeCode;

  @override
  Color get scaffoldColor => const Color(0xFF0F1115);
  @override
  Color get appBarBackgroundColor => const Color(0xFF161920);
  @override
  Color get appBarTextColor => Colors.white;
  @override
  Color get appBarBackButtonIconColor => const Color(0xFF60A5FA);
  @override
  Color get scrollbarColor => const Color(0xFF3B82F6);

  @override
  Color get generalTextColor => const Color(0xFFF3F4F6);
  @override
  Color get settingsTextColor => const Color(0xFFF9FAFB);
  @override
  Color get settingsIconsColor => const Color(0xFF60A5FA);
  @override
  Color get settingsSwitchListTileActiveThumbColor => const Color(0xFF3B82F6);
  @override
  Color get settingsSwitchListTileInactiveThumbColor => const Color(0xFF64748B);
  @override
  Color get settingsSwitchListTileInactiveTrackColor => const Color(0xFF1E222B);

  @override
  Color get searchBarPlaceholderColor => const Color(0xFF94A3B8);
  @override
  Color get searchBarTextColor => Colors.white;
  @override
  Color get searchBarBackgroundColor => const Color(0xFF1E222B);

  @override
  Color get popupMenuBackgroundColor => const Color(0xFF1A1D24);
  @override
  Color get popupMenuTextColor => Colors.white;

  @override
  Color get sourcesDropdownBackgroundColor => const Color(0xFF1E222B);
  @override
  Color get sourcesDropdownOpenedBackgroundColor => const Color(0xFF161920);
  @override
  Color get dropdownArrowDownColor => const Color(0xFF60A5FA);

  @override
  Color get sourceLabelColor => const Color(0xFF60A5FA);
  @override
  Color get categoryLabelColor => const Color(0xFF38BDF8);
  @override
  Color get cardColor => const Color(0xFF1A1D24);

  @override
  Color get cardPrimaryTextColor => Colors.white;
  @override
  Color get cardSecondaryTextColor => const Color(0xFFCBD5E1);

  @override
  Color get leechersIconColor => const Color(0xFFF87171);
  @override
  Color get leechersTextColor => const Color(0xFFF87171);
  @override
  Color get seedersIconColor => const Color(0xFF4ADE80);
  @override
  Color get seedersTextColor => const Color(0xFF4ADE80);
  @override
  Color get creationDateIconColor => const Color(0xFF94A3B8);
  @override
  Color get creationDateTextColor => const Color(0xFFE2E8F0);

  @override
  Color get magnetIconColor => const Color(0xFFE879F9);

  @override
  Color get bookmarkIconColor => const Color(0xFF60A5FA);
  @override
  Color get bookmarkedIconColor => const Color(0xFFFBBF24);

  @override
  Color get sourceUrlAvailableColor => const Color(0xFF38BDF8);
  @override
  Color get sourceUrlUnAvailableColor => const Color(0xFF64748B);

  @override
  Color get addTrackersListUrlTextFieldBackgroundColor =>
      const Color(0xFF1E222B);
  @override
  Color get addTrackersListUrlTextButtonTextColor => const Color(0xFF60A5FA);
  @override
  Color get addTrackersListUrlTextButtonBorderColor => const Color(0xFF3B82F6);

  @override
  Color get hyperlinkColor => const Color(0xFF60A5FA);
  @override
  Color get defaultTrackersInfoColor => Colors.white;
  @override
  Color get defaultTrackersTextColor => Colors.white;
  @override
  Color get defaultTrackersIconColor => const Color.fromARGB(255, 236, 237, 238);
  @override
  Color get defaultTrackersInfoDialogBackgroundColor => const Color(0xFF1A1D24);
  @override
  Color get defaultTrackersInfoDialogCloseTextColor => Colors.white;
  @override
  Color get defaultTrackersInfoDialogCloseTextButtonBackgroundColor =>
      const Color(0xFF334155);
  @override
  Color get defaultTrackersInfoIconColor => const Color(0xFF60A5FA);
  @override
  Color get activeTrackersListIconColor => const Color.fromARGB(255, 0, 81, 255);

  @override
  Color get paginationCurrentTextColor => Colors.white;
  @override
  Color get paginationNextButtonBackgroundColor => const Color(0xFF2563EB);
  @override
  Color get paginationPreviousButtonBackgroundColor => const Color(0xFF2563EB);

  @override
  Color get textFormFieldInactiveColor => const Color(0xFF475569);
  @override
  Color get textFormFieldActiveColor => const Color(0xFF3B82F6);

  @override
  Color get aboutDialogBackgroundColor => const Color(0xFF1A1D24);
  @override
  Color get aboutDialogIconColor => const Color(0xFF60A5FA);
  @override
  Color get aboutDialogHyperlinkTextColor => const Color(0xFF60A5FA);
  @override
  Color get aboutDialogTextColor => Colors.white;

  @override
  Color get settingsFloatingActionButtonForegroundColor => Colors.white;
  @override
  Color get settingsFloatingActionButtonBackgroundColor =>
      Colors.transparent;
  @override
  Color get settingsFloatingActionButtonHoverBackgroundColor =>
      Colors.transparent;

  @override
  Color get circularProgressIndicatorColor => const Color(0xFF3B82F6);

  @override
  Color get proxyDropdownBackgroundColor => const Color(0xFF1E222B);
  @override
  Color get proxyProtocolTextColor => Colors.white;
  @override
  Color get proxyProtocolArrowDropdownIconColor => const Color(0xFF60A5FA);
  @override
  Color get proxyIconColor => const Color(0xFF4ADE80);
  @override
  Color get proxyTextColor => Colors.white;
  @override
  Color get proxyDeleteIconColor => const Color(0xFFEF4444);
  @override
  Color get proxyFormFieldIconColor => const Color(0xFF4ADE80);
  @override
  Color get proxyFormFieldValidationErrorMessageColor =>
      const Color(0xFFEF4444);
  @override
  Color get proxySaveButtonBackgroundColor => const Color(0xFF2563EB);
  @override
  Color get proxySaveButtonTextColor => Colors.white;
  @override
  Color get proxySaveButtonBorderColor => const Color(0xFF3B82F6);

  @override
  Color get activeThemeIconColor => const Color(0xFF3B82F6);

  @override
  Color get contributeGetInvolvedIconColor => const Color(0xFF60A5FA);
  @override
  Color get contributeSourceCodeIconColor => Colors.white;
  @override
  Color get contributeSupportDevelopmentDonationIconColor => Colors.white;
  @override
  Color get contributeCryptoAddressBorderColor => const Color(0xFF3B82F6);
  @override
  Color get contributeCardBackgroundColor => const Color(0xFF1A1D24);
  @override
  Color get contributeCardShadowColor => Colors.black;
  @override
  Color get contributeCryptoAddressTextColor => Colors.white;
  @override
  Color get contributeCryptoAddressBackgroundColor => const Color(0xFF0F1115);
  @override
  Color get contributeCryptoAddressButtonBackgroundColor =>
      const Color(0xFF2563EB);

  @override
  Color get scrollToTopButtonBackgroundColor => const Color(0xFF2563EB);
  @override
  Color get scrollToTopButtonIconColor => Colors.white;

  @override
  Color get scaffoldMessengerMessageColor => Colors.white;
  @override
  Color get scaffoldMessengerBorderColor => const Color(0xFF3B82F6);
  @override
  Color get scaffoldMessengerBackgroundColor => const Color(0xFF161920);

  @override
  Color get categoryChipBackgroundColor => const Color(0xFF1E222B);
  @override
  Color get categoryChipTextColor => const Color(0xFFE2E8F0);
  @override
  Color get categoryChipActiveTextColor => const Color(0xFF60A5FA);
  @override
  Color get categoryChipBorderColor => const Color(0xFF334155);
  @override
  Color get categoryChipActiveBorderColor => const Color(0xFF3B82F6);

  @override
  Color get newCategoryTextColor => const Color(0xFF60A5FA);
  @override
  Color get newCategoryBackgroundColor => const Color(0xFF1E222B);
  @override
  Color get newCategoryBorderColor => const Color(0xFF334155);
  @override
  Color get createCategoryDialogBackgroundColor => const Color(0xFF1A1D24);
  @override
  Color get bookmarkCategoryOptionPopupMenuBackgroundColor =>
      const Color(0xFF161920);
  @override
  Color get bookmarkCategoryOptionPopupMenuIconColor => Colors.white;
  @override
  Color get createNewCategoryDialogTextFieldHintColor =>
      const Color(0xFF94A3B8);
  @override
  Color get createNewCategoryDialogTextFieldInputTextColor => Colors.white;
  @override
  Color get createNewCategoryDialogTextFieldInputActiveBorderColor =>
      const Color(0xFF3B82F6);
  @override
  Color get createNewCategoryDialogTextFieldInputInactiveBorderColor =>
      const Color(0xFF475569);
  @override
  Color get createNewCategoryDialogCreateButtonTextColor =>
      const Color(0xFF4ADE80);
  @override
  Color get createNewCategoryDialogCancelButtonTextColor =>
      const Color(0xFF94A3B8);
  @override
  Color get createNewCategoryDialogTitleTextColor => Colors.white;

  @override
  Color get bookmarkCategoryDialogBackgroundColor => const Color(0xFF1A1D24);
  @override
  Color get bookmarkCategoryDialogTextColor => Colors.white;
  @override
  Color get bookmarkCategoryIconColor => const Color(0xFF60A5FA);
  @override
  Color get bookmarkCategoryDialogCategoryTextColor => Colors.white;
  @override
  Color get bookmarkCategoryDialogCloseButtonBackgroundColor =>
      const Color(0xFF334155);
  @override
  Color get bookmarkCategoryDialogCloseButtonTextColor => Colors.white;
  @override
  Color get bookmarkCategoryDialogRemoveIconColor => const Color(0xFFEF4444);

  @override
  Brightness get statusBarIconBrightness => Brightness.light;
  @override
  Brightness get statusBarBrightness => Brightness.dark;

  @override
  Color get bookmarksStatsIconColor => const Color(0xFF60A5FA);
  @override
  Color get bookmarksStatsBorderColor => const Color(0xFF334155);
  @override
  Color get bookmarksStatsColumnHeaderTextColor => const Color(0xFF60A5FA);
  @override
  Color get bookmarksStatsTotalTextColor => const Color(0xFF4ADE80);
  @override
  Color get bookmarksStatsCategoryDataTextColor => Colors.white;

  @override
  Color get deleteCategoryConfirmationDialogTitleColor => Colors.white;
  @override
  Color get deleteCategoryConfirmationDialogTextColor => Colors.white;
  @override
  Color get deleteCategoryConfirmationDialogCodeColor =>
      const Color(0xFFEF4444);
  @override
  Color get deleteCategoryConfirmationDialogCodeBorderColor =>
      const Color(0xFFEF4444);
  @override
  Color get deleteCategoryConfirmationDialogInputTextfieldInactiveBorderColor =>
      const Color(0xFF475569);
  @override
  Color get deleteCategoryConfirmationDialogInputTextfieldActiveBorderColor =>
      const Color(0xFF3B82F6);
  @override
  Color get deleteCategoryConfirmationDialogInputTextColor => Colors.white;
  @override
  Color get deleteCategoryConfirmationDialogCancelButtonTextColor =>
      const Color(0xFF94A3B8);
  @override
  Color get deleteCategoryConfirmationDialogCancelButtonBackgroundColor =>
      const Color(0xFF334155);
  @override
  Color get deleteCategoryConfirmationDialogDeleteButtonTextColor =>
      const Color(0xFFEF4444);
  @override
  Color get deleteCategoryConfirmationDialogCodeDoesnotMatchErrorTextColor =>
      const Color(0xFFEF4444);

  @override
  Color get searchBookmarksPlaceholderTextColor => const Color(0xFF94A3B8);
  @override
  Color get searchBookmarksIconColor => const Color(0xFF60A5FA);
  @override
  Color get searchBookmarksClearIconColor => const Color(0xFFEF4444);

  @override
  Color get addTagIconColor => const Color(0xFF60A5FA);
  @override
  Color get tagPickerDialogBackgroundColor => const Color(0xFF1A1D24);
  @override
  Color get tagPickerDialogTitleColor => Colors.white;
  @override
  Color get tagPickerDialogTextColor => Colors.white;
  @override
  Color get tagPickerDialogCloseButtonBackgroundColor =>
      const Color(0xFF334155);
  @override
  Color get tagPickerDialogCloseButtonTextColor => Colors.white;
  @override
  Color get tagPickerDialogDoneButtonBackgroundColor =>
      const Color(0xFF2563EB);
  @override
  Color get tagPickerDialogDoneButtonTextColor => Colors.white;
  @override
  Color get tagCheckboxActiveColor => const Color(0xFF2563EB);
  @override
  Color get tagCheckboxTickColor => Colors.white;

  @override
  Color get addTorrentManuallyFormTextFieldInActiveBorderColor =>
      const Color(0xFF475569);
  @override
  Color get addTorrentManuallyFormTextFieldActiveBorderColor =>
      const Color(0xFF3B82F6);
  @override
  Color get addTorrentManuallyFormTextFieldLabelTextColor => Colors.white;
  @override
  Color get addTorrentManuallyFormTextFieldErrorMessageColor =>
      const Color(0xFFEF4444);
  @override
  Color get addTorrentManuallyFormSelectedCategoryBGColor =>
      const Color(0xFF2563EB);
  @override
  Color get addTorrentManuallyFormCheckmarkColor => Colors.white;
  @override
  Color get addTorrentManuallyFormSelectedCategoryNameTextColor => Colors.white;
  @override
  Color get addTorrentManuallyFormUnSelectedCategoryNameTextColor =>
      const Color(0xFF94A3B8);
  @override
  Color get addTorrentManuallyFormTagsNotCreatedYetMessageTextColor =>
      const Color(0xFF94A3B8);
  @override
  Color get addTorrentManuallyFormSelectedTagBGColor => const Color(0xFF2563EB);
  @override
  Color get addTorrentManuallyFormSelectedTagNameTextColor => Colors.white;
  @override
  Color get addTorrentManuallyFormUnSelectedTagNameTextColor =>
      const Color(0xFF94A3B8);
  @override
  Color get addTorrentManuallyFormAddTorrentButtonBackgroundColor =>
      const Color(0xFF2563EB);
  @override
  Color get addTorrentManuallyFormAddTorrentButtonBorderColor =>
      const Color(0xFF3B82F6);
  @override
  Color get addTorrentManuallyFormAddTorrentButtonTextColor => Colors.white;
  @override
  Color get addTorrentManuallyFormExpandIconColor => Colors.white;
  @override
  Color get addTorrentManuallyFormCollapseIconColor => const Color(0xFF60A5FA);
  @override
  Color get addTorrentManuallyFormInputTextColor => Colors.white;

  @override
  Color get torrentCardCopyButtonIconColor => const Color(0xFF60A5FA);
  @override
  Color get torrentCardCopyMenuBackgroundColor => const Color(0xFF161920);
  @override
  Color get torrentCardCopyMenuTextColor => Colors.white;
  @override
  Color get torrentCardCopyMenuIconColor => const Color(0xFF60A5FA);
  @override
  Color get torrentCardCopyMenuBorderColor => const Color(0xFF334155);
}
