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

      return AlertDialog(
        backgroundColor: context.appColors.createCategoryDialogBackgroundColor,
        title: Text(
          title,
          style: TextStyle(
            color: context.appColors.createNewCategoryDialogTitleTextColor,
          ),
        ),

        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (_) => handleCreate(),
          style: TextStyle(
            color: context
                .appColors
                .createNewCategoryDialogTextFieldInputTextColor,
          ),

          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color:
                  context.appColors.createNewCategoryDialogTextFieldHintColor,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: context
                    .appColors
                    .createNewCategoryDialogTextFieldInputInactiveBorderColor,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: context
                    .appColors
                    .createNewCategoryDialogTextFieldInputActiveBorderColor,
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: context
                      .appColors
                      .deleteCategoryConfirmationDialogCancelButtonBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: context
                        .appColors
                        .createNewCategoryDialogCancelButtonTextColor,
                  ),
                ),
              ),

              const Spacer(),

              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: context
                      .appColors
                      .deleteCategoryConfirmationDialogCancelButtonBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                onPressed: handleCreate,
                child: Text(
                  'Create',
                  style: TextStyle(
                    color: context
                        .appColors
                        .createNewCategoryDialogCreateButtonTextColor,
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

      return AlertDialog(
        backgroundColor: context.appColors.createCategoryDialogBackgroundColor,
        title: Text(
          title,
          style: TextStyle(
            color: context.appColors.createNewCategoryDialogTitleTextColor,
          ),
        ),
        content: TextField(
          style: TextStyle(
            color: context
                .appColors
                .createNewCategoryDialogTextFieldInputTextColor,
          ),

          decoration: InputDecoration(
            hintText: currentName,
            hintStyle: TextStyle(
              color:
                  context.appColors.createNewCategoryDialogTextFieldHintColor,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: context
                    .appColors
                    .createNewCategoryDialogTextFieldInputInactiveBorderColor,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: context
                    .appColors
                    .createNewCategoryDialogTextFieldInputActiveBorderColor,
                width: 2,
              ),
            ),
          ),
          controller: textController,
          autofocus: true,
          onSubmitted: (_) => handleRename(),
        ),
        actions: [
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: context
                      .appColors
                      .deleteCategoryConfirmationDialogCancelButtonBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: context
                        .appColors
                        .createNewCategoryDialogCancelButtonTextColor,
                  ),
                ),
              ),

              const Spacer(),

              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: context
                      .appColors
                      .deleteCategoryConfirmationDialogCancelButtonBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: handleRename,
                child: Text(
                  "Rename",
                  style: TextStyle(
                    color: context
                        .appColors
                        .createNewCategoryDialogCreateButtonTextColor,
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
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor:
                context.appColors.createCategoryDialogBackgroundColor,
            title: Text(
              title,
              style: TextStyle(
                color: context
                    .appColors
                    .deleteCategoryConfirmationDialogTitleColor,
              ),
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
                        color: context
                            .appColors
                            .deleteCategoryConfirmationDialogTextColor,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Type the code below to confirm:',
                      style: TextStyle(
                        color: context
                            .appColors
                            .deleteCategoryConfirmationDialogTextColor,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context
                              .appColors
                              .deleteCategoryConfirmationDialogCodeBorderColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        verificationCode,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context
                              .appColors
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
                        color: context
                            .appColors
                            .deleteCategoryConfirmationDialogInputTextColor,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter code',
                        hintStyle: TextStyle(
                          color: context
                              .appColors
                              .createNewCategoryDialogTextFieldHintColor,
                          letterSpacing: 1,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context
                                .appColors
                                .deleteCategoryConfirmationDialogInputTextfieldInactiveBorderColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context
                                .appColors
                                .deleteCategoryConfirmationDialogInputTextfieldActiveBorderColor,
                            width: 2,
                          ),
                        ),
                        // show error if code doesn't match
                        errorText: showError ? 'Code did not matched' : null,
                        errorStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context
                              .appColors
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
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: context
                          .appColors
                          .deleteCategoryConfirmationDialogCancelButtonBackgroundColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: context
                            .appColors
                            .deleteCategoryConfirmationDialogCancelButtonTextColor,
                      ),
                    ),
                  ),
                  const Spacer(),

                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: context
                          .appColors
                          .deleteCategoryConfirmationDialogCancelButtonBackgroundColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                        color: context
                            .appColors
                            .deleteCategoryConfirmationDialogDeleteButtonTextColor,
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
