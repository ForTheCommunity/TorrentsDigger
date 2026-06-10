import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/category_bloc/category_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/routes/routes_name.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/category_chip.dart';
import 'package:torrents_digger/ui/widgets/floating_action_buttons.dart';
import 'package:torrents_digger/ui/widgets/torrent_list_widget.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarksScreen> {
  int? selectedCategoryId = 0;

  @override
  void initState() {
    super.initState();
    // Dispatching the load event immediately when the screen initializes
    context.read<CategoryBloc>().add(const CategoryEvent.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: TextStyle(
            color: context.appColors.appBarTextColor,
            letterSpacing: 2,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.query_stats,
              size: 28,
              color: context.appColors.bookmarksStatsIconColor,
            ),
            onPressed: () {
              Navigator.pushNamed(context, RoutesName.bookmarkStatsScreen);
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionsButtons(
        scrollToTop: true,
        enableBookmarks: false,
        enableCustoms: true,
        enableSettings: true,
      ),

      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            primary: true,

            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal:
                    Platform.isLinux || Platform.isWindows || Platform.isMacOS
                    ? 15
                    : (Platform.isAndroid || Platform.isIOS ? 7.0 : 7.0),
              ),

              child: Column(
                children: [
                  // Category Section
                  BlocConsumer<CategoryBloc, CategoryState>(
                    listener: (context, state) {
                      state.whenOrNull(
                        loaded: (_) {
                          context.read<BookmarkBloc>().add(
                            BookmarkEvent.loadBookmarks(
                              categoryID: selectedCategoryId ?? 0,
                            ),
                          );
                        },
                      );
                    },
                    builder: (context, state) {
                      return state.when(
                        initial: () => const SizedBox.shrink(),
                        loading: () => const CircularProgressBarWidget(),
                        loaded: (categoriesList) =>
                            _buildCategoryGrid(context, categoriesList),
                      );
                    },
                  ),

                  const Divider(height: 1, thickness: 1),

                  // Bookmarked Torrents UI Section.
                  BlocBuilder<BookmarkBloc, BookmarkState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () => const Text("Initial State"),
                        loading: () => const SizedBox(
                          height: 400,
                          child: Center(child: CircularProgressBarWidget()),
                        ),
                        loaded: (torrents, _, _) => torrents.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      "This Category has 0 Torrents.",
                                      style: TextStyle(
                                        color:
                                            context.appColors.generalTextColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : TorrentListWidget(torrents: torrents),
                        error: (e) =>
                            Center(child: Text("Error : ${e.toString()}")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    List<InternalBookmarkCategory> categoriesList,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),

      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...categoriesList.map((category) {
              final currentId = category.id;
              bool isSelected = selectedCategoryId == category.id;

              return CategoryChip(
                label: category.name,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    selectedCategoryId = currentId;
                  });
                  context.read<BookmarkBloc>().add(
                    BookmarkEvent.loadBookmarks(categoryID: currentId),
                  );
                },

                // more options related to a category
                trailing: isSelected && category.id != 0
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
                          itemBuilder: (context) {
                            // disabling for uncategorized category.
                            if (category.id == 0) {
                              return const <PopupMenuEntry<String>>[];
                            }
                            return <PopupMenuEntry<String>>[
                              PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                                onTap: () {
                                  _renameCategoryDialog(
                                    context,
                                    category.id,
                                    category.name,
                                  );
                                },
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: const Text('Delete'),
                                onTap: () {
                                  _deleteCategoryVerificationDialog(
                                    context,
                                    currentId,
                                  );
                                },
                              ),
                            ];
                          },
                        ),
                      )
                    : null,
              );
            }),

            GestureDetector(
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
                  "New Category +",
                  style: TextStyle(
                    color: context.appColors.newCategoryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                _createCategoryDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCategoryDialog(BuildContext context) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              context.appColors.createCategoryDialogBackgroundColor,
          title: Text(
            'New Category',
            style: TextStyle(
              color: context.appColors.createNewCategoryDialogTitleTextColor,
            ),
          ),

          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(
              color: context
                  .appColors
                  .createNewCategoryDialogTextFieldInputTextColor,
            ),

            decoration: InputDecoration(
              hintText: 'Category Name',
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
                  child: Text(
                    'Create',
                    style: TextStyle(
                      color: context
                          .appColors
                          .createNewCategoryDialogCreateButtonTextColor,
                    ),
                  ),
                  onPressed: () {
                    final newCatName = controller.text.trim();

                    context.read<CategoryBloc>().add(
                      CategoryEvent.create(newCategoryName: newCatName),
                    );

                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameCategoryDialog(
    BuildContext context,
    int categoryID,
    String currentCategoryName,
  ) async {
    final textController = TextEditingController(text: currentCategoryName);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              context.appColors.createCategoryDialogBackgroundColor,
          title: Text(
            'Rename Category',
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
              hintText: 'Category Name',
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
          ),
          actions: [
            Row(
              children: [
                TextButton(
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
                  child: Text(
                    "Rename",
                    style: TextStyle(
                      color: context
                          .appColors
                          .createNewCategoryDialogCreateButtonTextColor,
                    ),
                  ),
                  onPressed: () {
                    final newCategoryName = textController.text.trim();
                    if (newCategoryName.isEmpty) {
                      return;
                    }

                    if (currentCategoryName == newCategoryName) {
                      return;
                    }

                    context.read<CategoryBloc>().add(
                      CategoryEvent.rename(
                        categoryId: categoryID,
                        oldCategoryName: currentCategoryName,
                        newCategoryName: newCategoryName,
                      ),
                    );
                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCategoryVerificationDialog(
    BuildContext context,
    int categoryID,
  ) async {
    // generating random verification code
    const chars = 'ABCDEFGHIJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz123456789';
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
                'Delete Category',
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
                        'This will delete category and all torrents inside that category !!!',
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
                      onPressed: () {
                        if (controller.text.trim() == verificationCode) {
                          context.read<CategoryBloc>().add(
                            CategoryEvent.delete(categoryID: categoryID),
                          );
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
}
