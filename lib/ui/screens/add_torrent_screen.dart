import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmark_bloc/bookmark_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/category_bloc/category_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/tags_bloc/tags_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/database/bookmarks.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

class AddTorrentScreen extends StatefulWidget {
  const AddTorrentScreen({super.key});

  @override
  State<AddTorrentScreen> createState() => _AddTorrentScreenState();
}

class _AddTorrentScreenState extends State<AddTorrentScreen> {
  final _formKey = GlobalKey<FormState>();

  String _torrentName = '';
  String _infoHash = '';
  String _torrentSize = '';
  String _creationDate = '';
  String _seeders = '';
  String _leechers = '';
  String _totalDownloads = '';
  String? _sourceUrl;

  final TextEditingController _magnetController = TextEditingController();

  int _selectedCategoryID = 0;
  final Set<int> _selectedTagIds = {};

  @override
  void dispose() {
    _magnetController.dispose();
    super.dispose();
  }

  void _updateMagnetLink(String hash) {
    final cleanHash = hash.trim();
    if (cleanHash.isEmpty) {
      _magnetController.text = '';
    } else {
      _magnetController.text = 'magnet:?xt=urn:btih:$cleanHash';
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await bookmarkTorrentManually(
          torrentName: _torrentName.trim(),
          infoHash: _infoHash.trim(),
          magnetLink: _magnetController.text.trim(),
          torrentSize: _torrentSize,
          creationDate: _creationDate.isEmpty ? "N/A" : _creationDate,
          seeders: _seeders.isEmpty ? "N/A" : _seeders,
          leechers: _leechers.isEmpty ? "N/A" : _leechers,
          totalDownloads: _totalDownloads.isEmpty ? "N/A" : _totalDownloads,
          sourceUrl: _sourceUrl,
          categoryId: _selectedCategoryID,
          tagIds: _selectedTagIds.toList(),
        );

        // Check if widget is still in the tree before using context after an await
        if (!mounted) return;

        context.read<BookmarkedIhBloc>().add(
          BookmarkedIhEvent.addInfoHash(infoHash: _infoHash.trim()),
        );
        context.read<BookmarkBloc>().add(
          BookmarkEvent.loadBookmarks(
            categoryID: 65535,
            tagID: 65535,
            limit: 10,
            offset: 0,
          ),
        );
        Navigator.pop(context);
        createSnackBar(message: "Added Torrent...", duration: 2);
      } catch (e) {
        createSnackBar(message: "Error : ${e.toString()}", duration: 10);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Torrent',
          style: TextStyle(color: context.appColors.appBarTextColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(17.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Torrent Name
                TextFormField(
                  style: TextStyle(
                    color: context.appColors.addTorrentManuallyFormInputTextColor
                  ),
                  decoration: InputDecoration(
                    labelText: 'Torrent Name',
                    labelStyle: TextStyle(
                      color: context
                          .appColors
                          .addTorrentManuallyFormTextFieldLabelTextColor,
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: context
                            .appColors
                            .addTorrentManuallyFormTextFieldInActiveBorderColor,
                        width: 1.0,
                      ),
                    ),
                    errorStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context
                          .appColors
                          .addTorrentManuallyFormTextFieldErrorMessageColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: context
                            .appColors
                            .addTorrentManuallyFormTextFieldActiveBorderColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  onChanged: (value) => _torrentName = value,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Torrent Name can't be empty";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Info Hash
                TextFormField(
                  style: TextStyle(
                    color: context.appColors.addTorrentManuallyFormInputTextColor
                  ),
                  decoration: InputDecoration(
                    labelText: 'Info Hash',
                    labelStyle: TextStyle(
                      color: context
                          .appColors
                          .addTorrentManuallyFormTextFieldLabelTextColor,
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: context
                            .appColors
                            .addTorrentManuallyFormTextFieldInActiveBorderColor,
                        width: 1.0,
                      ),
                    ),
                    errorStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context
                          .appColors
                          .addTorrentManuallyFormTextFieldErrorMessageColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: context
                            .appColors
                            .addTorrentManuallyFormTextFieldActiveBorderColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _infoHash = value;
                      _updateMagnetLink(value);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Info Hash can't be empty";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Magnet Link
                TextFormField(
                  style: TextStyle(
                    color: context.appColors.addTorrentManuallyFormInputTextColor
                  ),
                  controller: _magnetController,
                  decoration: InputDecoration(
                    labelText: 'Magnet Link',
                    labelStyle: TextStyle(
                      color: context
                          .appColors
                          .addTorrentManuallyFormTextFieldLabelTextColor,
                    ),

                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: context
                            .appColors
                            .addTorrentManuallyFormTextFieldInActiveBorderColor,
                        width: 1.0,
                      ),
                    ),
                    errorStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context
                          .appColors
                          .addTorrentManuallyFormTextFieldErrorMessageColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: context
                            .appColors
                            .addTorrentManuallyFormTextFieldActiveBorderColor,
                        width: 2.0,
                      ),
                    ),
                    hintText: 'Will auto-generate from Info Hash',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Magnet Link can't be empty";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 23),

                // Size
                TextFormField(
                  style: TextStyle(
                    color: context.appColors.addTorrentManuallyFormInputTextColor
                  ),
                  decoration: InputDecoration(
                    labelText: 'Size',
                    labelStyle: TextStyle(
                      color: context
                          .appColors
                          .addTorrentManuallyFormTextFieldLabelTextColor,
                    ),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: context
                            .appColors
                            .addTorrentManuallyFormTextFieldInActiveBorderColor,
                        width: 1.0,
                      ),
                    ),
                    errorStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context
                          .appColors
                          .addTorrentManuallyFormTextFieldErrorMessageColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: context
                            .appColors
                            .addTorrentManuallyFormTextFieldActiveBorderColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _torrentSize = value;
                  },

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Size is required";
                    }

                    final sizeRegex = RegExp(
                      r'^(\d+(?:\.\d+)?)\s*(B|KB|KIB|MB|MIB|GB|GIB|TB|TIB)$',
                      caseSensitive: false,
                    );

                    final trimmedValue = value.trim();
                    final match = sizeRegex.firstMatch(trimmedValue);

                    if (match == null) {
                      return 'Use valid units: B, KB, KiB, MB, MiB, GB, GiB, TB, TiB';
                    }

                    // group(1) extracts the full number
                    String numberPart = match.group(1)!;
                    // group(2) extracts the unit
                    String unitPart = match.group(2)!.toUpperCase();

                    _torrentSize = "$numberPart $unitPart";

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Collapsible Optional Fields Section
                ExpansionTile(
                  iconColor:
                      context.appColors.addTorrentManuallyFormCollapseIconColor,
                  collapsedIconColor:
                      context.appColors.addTorrentManuallyFormExpandIconColor,
                  title: Text(
                    "Optional Metadata (Seeders, Leechers, Source Url etc.)",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.generalTextColor,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: TextStyle(
                              color: context.appColors.addTorrentManuallyFormInputTextColor
                            ),
                            decoration: InputDecoration(
                              labelText: 'Creation Date (YYYY-MM-DD)',
                              labelStyle: TextStyle(
                                color: context
                                    .appColors
                                    .addTorrentManuallyFormTextFieldLabelTextColor,
                              ),
                              hintText: 'e.g., 2026-05-13',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: context
                                      .appColors
                                      .addTorrentManuallyFormTextFieldInActiveBorderColor,
                                  width: 1.0,
                                ),
                              ),
                              errorStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context
                                    .appColors
                                    .addTorrentManuallyFormTextFieldErrorMessageColor,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: context
                                      .appColors
                                      .addTorrentManuallyFormTextFieldActiveBorderColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            onChanged: (val) => _creationDate = val,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }

                              //  checking for YYYY-MM-DD structure
                              final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

                              if (!dateRegex.hasMatch(value.trim())) {
                                return 'Use format: YYYY-MM-DD (e.g., 2026-07-11)';
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            style: TextStyle(
                              color: context.appColors.addTorrentManuallyFormInputTextColor
                            ),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Seeders',
                              labelStyle: TextStyle(
                                color: context
                                    .appColors
                                    .addTorrentManuallyFormTextFieldLabelTextColor,
                              ),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: context
                                      .appColors
                                      .addTorrentManuallyFormTextFieldInActiveBorderColor,
                                  width: 1.0,
                                ),
                              ),
                              errorStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context
                                    .appColors
                                    .addTorrentManuallyFormTextFieldErrorMessageColor,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: context
                                      .appColors
                                      .addTorrentManuallyFormTextFieldActiveBorderColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            onChanged: (val) => _seeders = val,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              final numRegex = RegExp(r'^\d+$');
                              if (!numRegex.hasMatch(value.trim())) {
                                return 'Must be a whole number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: TextStyle(
                              color: context.appColors.addTorrentManuallyFormInputTextColor
                            ),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Leechers',
                              labelStyle: TextStyle(
                                color: context
                                    .appColors
                                    .addTorrentManuallyFormTextFieldLabelTextColor,
                              ),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: context
                                      .appColors
                                      .addTorrentManuallyFormTextFieldInActiveBorderColor,
                                  width: 1.0,
                                ),
                              ),
                              errorStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context
                                    .appColors
                                    .addTorrentManuallyFormTextFieldErrorMessageColor,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: context
                                      .appColors
                                      .addTorrentManuallyFormTextFieldActiveBorderColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            onChanged: (val) => _leechers = val,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              final numRegex = RegExp(r'^\d+$');
                              if (!numRegex.hasMatch(value.trim())) {
                                return 'Must be a whole number';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: TextFormField(
                            style: TextStyle(
                              color: context.appColors.addTorrentManuallyFormInputTextColor
                            ),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Total Downloads',
                              labelStyle: TextStyle(
                                color: context
                                    .appColors
                                    .addTorrentManuallyFormTextFieldLabelTextColor,
                              ),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: context
                                      .appColors
                                      .addTorrentManuallyFormTextFieldInActiveBorderColor,
                                  width: 1.0,
                                ),
                              ),
                              errorStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context
                                    .appColors
                                    .addTorrentManuallyFormTextFieldErrorMessageColor,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: context
                                      .appColors
                                      .addTorrentManuallyFormTextFieldActiveBorderColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            onChanged: (val) => _totalDownloads = val,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              final numRegex = RegExp(r'^\d+$');
                              if (!numRegex.hasMatch(value.trim())) {
                                return 'Must be a whole number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      style: TextStyle(
                        color: context.appColors.addTorrentManuallyFormInputTextColor
                      ),
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: 'Source URL',
                        labelStyle: TextStyle(
                          color: context
                              .appColors
                              .addTorrentManuallyFormTextFieldLabelTextColor,
                        ),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context
                                .appColors
                                .addTorrentManuallyFormTextFieldInActiveBorderColor,
                            width: 1.0,
                          ),
                        ),
                        errorStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context
                              .appColors
                              .addTorrentManuallyFormTextFieldErrorMessageColor,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context
                                .appColors
                                .addTorrentManuallyFormTextFieldActiveBorderColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (val) => _sourceUrl = val,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }

                        final uri = Uri.tryParse(value.trim());

                        if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
                          return 'Enter a valid URL (e.g. : https://example.com)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Category
                Text(
                  "Category",
                  style: TextStyle(
                    color: context.appColors.generalTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => const SizedBox.shrink(),
                      loading: () =>
                          const Center(child: CircularProgressBarWidget()),
                      loaded: (categoriesList) {
                        final filteredCategoriesList = categoriesList
                            .where((c) => c.id != 65535)
                            .toList();

                        return Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          children: filteredCategoriesList.map((category) {
                            final isSelected =
                                _selectedCategoryID == category.id;

                            return FilterChip(
                              label: Text(category.name),
                              selected: isSelected,
                              selectedColor: context
                                  .appColors
                                  .addTorrentManuallyFormSelectedCategoryBGColor,
                              checkmarkColor: context
                                  .appColors
                                  .addTorrentManuallyFormCheckmarkColor,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? context
                                          .appColors
                                          .addTorrentManuallyFormSelectedCategoryNameTextColor
                                    : context
                                          .appColors
                                          .addTorrentManuallyFormUnSelectedCategoryNameTextColor,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategoryID = category.id;
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Tags Section
                Text(
                  'Tags',
                  style: TextStyle(
                    color: context.appColors.generalTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                BlocBuilder<TagsBloc, TagsState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => const SizedBox.shrink(),
                      loading: () => const CircularProgressBarWidget(),
                      loaded: (tagsList) {
                        final filteredTagsList = tagsList
                            .where((t) => t.id != 65535)
                            .toList();

                        if (filteredTagsList.isEmpty) {
                          return Text(
                            'No tags yet, Create them from Bookmarks Screen...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context
                                  .appColors
                                  .addTorrentManuallyFormTagsNotCreatedYetMessageTextColor,
                              fontSize: 13,
                            ),
                          );
                        }

                        return Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          children: filteredTagsList.map((tag) {
                            final isSelected = _selectedTagIds.contains(tag.id);

                            return FilterChip(
                              label: Text(tag.name),
                              selected: isSelected,
                              selectedColor: context
                                  .appColors
                                  .addTorrentManuallyFormSelectedTagBGColor,
                              checkmarkColor: context
                                  .appColors
                                  .addTorrentManuallyFormCheckmarkColor,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? context
                                          .appColors
                                          .addTorrentManuallyFormSelectedTagNameTextColor
                                    : context
                                          .appColors
                                          .addTorrentManuallyFormUnSelectedTagNameTextColor,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTagIds.add(tag.id);
                                  } else {
                                    _selectedTagIds.remove(tag.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),

                // Add Torrent Button
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: context
                        .appColors
                        .addTorrentManuallyFormAddTorrentButtonBackgroundColor,
                    side: BorderSide(
                      color: context
                          .appColors
                          .addTorrentManuallyFormAddTorrentButtonBorderColor,
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Add Torrent',
                    style: TextStyle(
                      color: context
                          .appColors
                          .addTorrentManuallyFormAddTorrentButtonTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
