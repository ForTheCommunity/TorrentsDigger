import 'dart:math';
import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/ui/widgets/category_chip.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

Widget buildChipGrid({
  required BuildContext context,
  required List<(int id, String name)> items,
  required int? selectedID,
  required void Function(int id) onTap,
  required String newButtonLabel,
  required VoidCallback oneNewTap,
  List<PopupMenuEntry<String>> Function(int id)? menuBuilder,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...items.map((item) {
            final bool isSelected = selectedID == item.$1;
            return CategoryChip(
              label: item.$2,
              isSelected: isSelected,
              onTap: () => onTap(item.$1),
              trailing:
                  isSelected &&
                      item.$1 != 0 &&
                      item.$1 != 65535 &&
                      menuBuilder != null
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        color: context
                            .appColors
                            .bookmarkCategoryOptionPopupMenuBackgroundColor,
                        icon: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: context
                              .appColors
                              .bookmarkCategoryOptionPopupMenuIconColor,
                        ),
                        onSelected: (value) {},
                        itemBuilder: (_) => menuBuilder(item.$1),
                      ),
                    )
                  : null,
            );
          }),

          GestureDetector(
            onTap: oneNewTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: context.appColors.newCategoryBackgroundColor,
                border: Border.all(
                  color: context.appColors.newCategoryBorderColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                newButtonLabel,
                style: TextStyle(
                  color: context.appColors.newCategoryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> createItemDialog(
  BuildContext context, {
  required String title,
  required String hintText,
  required String emptyErrorMessage,
  required void Function(String name) onCreate,
}) async {
  final controller = TextEditingController();

  await showDialog(
    context: context,
    builder: (dialogContext) {
      final colors = context.appColors;

      void handleCreate() {
        final newName = controller.text.trim();
        if (newName.isEmpty) {
          Navigator.pop(dialogContext);
          createSnackBar(message: emptyErrorMessage, duration: 5);
          return;
        }
        onCreate(newName);
        Navigator.pop(dialogContext);
      }

      final isTag = title.toLowerCase().contains("tag");
      final IconData headerIcon =
          isTag ? Icons.local_offer_rounded : Icons.create_new_folder_rounded;
      final Color accentColor =
          isTag ? colors.bookmarksStatsIconColor : colors.bookmarkCategoryIconColor;

      return AlertDialog(
        backgroundColor: colors.createCategoryDialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                headerIcon,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: colors.createNewCategoryDialogTitleTextColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: colors.cardSecondaryTextColor.withValues(alpha: 0.7),
                size: 20,
              ),
              tooltip: 'Close',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
        content: SizedBox(
          width: 390,
          child: TextField(
            controller: controller,
            autofocus: true,
            onSubmitted: (_) => handleCreate(),
            style: TextStyle(
              color: colors.createNewCategoryDialogTextFieldInputTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: colors.createNewCategoryDialogTextFieldHintColor,
                fontSize: 14,
              ),
              filled: true,
              fillColor: colors.cardColor.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colors
                      .createNewCategoryDialogTextFieldInputInactiveBorderColor
                      .withValues(alpha: 0.7),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colors
                      .createNewCategoryDialogTextFieldInputActiveBorderColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: colors
                      .bookmarkCategoryDialogCloseButtonBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: colors
                        .bookmarkCategoryDialogCloseButtonTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: colors
                      .createNewCategoryDialogCreateButtonTextColor
                      .withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: colors
                          .createNewCategoryDialogCreateButtonTextColor
                          .withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                onPressed: handleCreate,
                child: Text(
                  'Create',
                  style: TextStyle(
                    color: colors
                        .createNewCategoryDialogCreateButtonTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

Future<void> renameItemDialog(
  BuildContext context, {
  required String title,
  required String currentName,
  required String emptyErrorMessage,
  required String sameNameErrorMessage,
  required void Function(String newName) onRename,
}) async {
  final textController = TextEditingController(text: currentName);

  await showDialog(
    context: context,
    builder: (dialogContext) {
      final colors = context.appColors;

      void handleRename() {
        final newName = textController.text.trim();

        if (newName.isEmpty) {
          Navigator.pop(dialogContext);
          createSnackBar(message: emptyErrorMessage, duration: 5);
          return;
        }

        if (newName == currentName) {
          Navigator.pop(dialogContext);
          createSnackBar(message: sameNameErrorMessage, duration: 5);
          return;
        }

        onRename(newName);
        Navigator.pop(dialogContext);
      }

      final isTag = title.toLowerCase().contains("tag");
      final Color accentColor =
          isTag ? colors.bookmarksStatsIconColor : colors.bookmarkCategoryIconColor;

      return AlertDialog(
        backgroundColor: colors.createCategoryDialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_rounded,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: colors.createNewCategoryDialogTitleTextColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: colors.cardSecondaryTextColor.withValues(alpha: 0.7),
                size: 20,
              ),
              tooltip: 'Close',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
        content: SizedBox(
          width: 390,
          child: TextField(
            controller: textController,
            autofocus: true,
            onSubmitted: (_) => handleRename(),
            style: TextStyle(
              color: colors.createNewCategoryDialogTextFieldInputTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: currentName,
              hintStyle: TextStyle(
                color: colors.createNewCategoryDialogTextFieldHintColor,
                fontSize: 14,
              ),
              filled: true,
              fillColor: colors.cardColor.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colors
                      .createNewCategoryDialogTextFieldInputInactiveBorderColor
                      .withValues(alpha: 0.7),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colors
                      .createNewCategoryDialogTextFieldInputActiveBorderColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: colors
                      .bookmarkCategoryDialogCloseButtonBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: colors
                        .bookmarkCategoryDialogCloseButtonTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: colors
                      .createNewCategoryDialogCreateButtonTextColor
                      .withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: colors
                          .createNewCategoryDialogCreateButtonTextColor
                          .withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                onPressed: handleRename,
                child: Text(
                  'Rename',
                  style: TextStyle(
                    color: colors
                        .createNewCategoryDialogCreateButtonTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

Future<void> deleteItemVerificationDialog(
  BuildContext context, {
  required String title,
  required String description,
  required void Function() onDelete,
}) async {
  // generating random verification code
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz123456789';
  final random = Random();
  final verificationCode = String.fromCharCodes(
    List.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
  );

  final controller = TextEditingController();
  bool showError = false;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      final colors = context.appColors;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: colors.createCategoryDialogBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.bookmarkCategoryDialogRemoveIconColor
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.delete_forever_rounded,
                    color: colors.bookmarkCategoryDialogRemoveIconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color:
                          colors.deleteCategoryConfirmationDialogTitleColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.cardSecondaryTextColor.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        color:
                            colors.deleteCategoryConfirmationDialogTextColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Type the code below to confirm:',
                      style: TextStyle(
                        color:
                            colors.deleteCategoryConfirmationDialogTextColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.cardColor.withValues(alpha: 0.5),
                        border: Border.all(
                          color: colors
                              .deleteCategoryConfirmationDialogCodeBorderColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        verificationCode,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors
                              .deleteCategoryConfirmationDialogCodeColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      autofocus: false,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors
                            .deleteCategoryConfirmationDialogInputTextColor,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter code',
                        hintStyle: TextStyle(
                          color: colors
                              .createNewCategoryDialogTextFieldHintColor,
                          letterSpacing: 1,
                        ),
                        filled: true,
                        fillColor: colors.cardColor.withValues(alpha: 0.5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors
                                .deleteCategoryConfirmationDialogInputTextfieldInactiveBorderColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colors
                                .deleteCategoryConfirmationDialogInputTextfieldActiveBorderColor,
                            width: 1.5,
                          ),
                        ),
                        // show error if code doesn't match
                        errorText: showError ? 'Code did not match' : null,
                        errorStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors
                              .deleteCategoryConfirmationDialogCodeDoesnotMatchErrorTextColor,
                        ),
                      ),
                      onChanged: (_) {
                        if (showError) {
                          setDialogState(() => showError = false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: colors
                          .bookmarkCategoryDialogCloseButtonBackgroundColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: colors
                            .deleteCategoryConfirmationDialogCancelButtonTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: colors
                          .deleteCategoryConfirmationDialogDeleteButtonTextColor
                          .withValues(alpha: 0.15),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: colors
                              .deleteCategoryConfirmationDialogDeleteButtonTextColor
                              .withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (controller.text.trim() == verificationCode) {
                        onDelete();
                        Navigator.pop(dialogContext);
                      } else {
                        // show error inside dialog
                        setDialogState(() => showError = true);
                      }
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: colors
                            .deleteCategoryConfirmationDialogDeleteButtonTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
