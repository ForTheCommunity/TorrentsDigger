import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/customs_blocs/customs_dropdown_bloc/customs_bloc.dart';
import 'package:torrents_digger/blocs/customs_blocs/customs_torrents/customs_torrents_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/configs/nsfw_helper.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/dropdown_widget.dart';
import 'package:torrents_digger/ui/widgets/floating_action_buttons.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:torrents_digger/ui/widgets/torrent_list_widget.dart';

enum _CustomsSortOption {
  none,
  seedersDesc,
  sizeDesc,
  nameAsc,
}

class CustomsScreen extends StatefulWidget {
  const CustomsScreen({super.key});

  @override
  State<CustomsScreen> createState() => _CustomsScreenState();
}

class _CustomsScreenState extends State<CustomsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearching = false;
  String _searchQuery = "";
  _CustomsSortOption _sortOption = _CustomsSortOption.none;

  @override
  void initState() {
    super.initState();
    final customsBloc = context.read<CustomsBloc>();
    if (customsBloc.state.maybeWhen(initial: () => true, orElse: () => false)) {
      customsBloc.add(const CustomsEvent.loadCustoms());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  int _parseSeeders(String seedersStr) {
    final clean = seedersStr.replaceAll(',', '').replaceAll('+', '').trim();
    return int.tryParse(clean) ?? 0;
  }

  double _parseSizeInBytes(String sizeStr) {
    final clean = sizeStr.trim().toUpperCase();
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.isEmpty) return 0;
    final num = double.tryParse(parts[0]) ?? 0;
    if (parts.length > 1) {
      final unit = parts[1];
      if (unit.startsWith('T')) return num * 1024 * 1024 * 1024 * 1024;
      if (unit.startsWith('G')) return num * 1024 * 1024 * 1024;
      if (unit.startsWith('M')) return num * 1024 * 1024;
      if (unit.startsWith('K')) return num * 1024;
    }
    return num;
  }

  String _sortOptionLabel(_CustomsSortOption option) {
    switch (option) {
      case _CustomsSortOption.none:
        return "Default";
      case _CustomsSortOption.seedersDesc:
        return "Seeders ↓";
      case _CustomsSortOption.sizeDesc:
        return "Size ↓";
      case _CustomsSortOption.nameAsc:
        return "Name A-Z";
    }
  }

  PopupMenuItem<_CustomsSortOption> _buildSortMenuItem(
    BuildContext context,
    _CustomsSortOption option,
    String label,
    IconData icon,
  ) {
    final isSelected = _sortOption == option;
    final colors = context.appColors;

    return PopupMenuItem<_CustomsSortOption>(
      value: option,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected
                ? colors.bookmarksSidebarSelectedTileTextColor
                : colors.cardSecondaryTextColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colors.bookmarksSidebarSelectedTileTextColor
                    : colors.settingsTextColor,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_rounded,
              size: 18,
              color: colors.bookmarksSidebarSelectedTileTextColor,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customsTorrentsState = context.watch<CustomsTorrentsBloc>().state;
    final List<InternalTorrent> rawTorrents = customsTorrentsState.maybeWhen(
      loaded: (torrents) => torrents,
      orElse: () => const [],
    );

    // Apply search filter
    List<InternalTorrent> filteredTorrents = List.of(rawTorrents);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredTorrents = filteredTorrents.where((t) {
        return t.name.toLowerCase().contains(q) ||
            t.infoHash.toLowerCase().contains(q);
      }).toList();
    }

    // Apply sort
    switch (_sortOption) {
      case _CustomsSortOption.seedersDesc:
        filteredTorrents.sort(
          (a, b) =>
              _parseSeeders(b.seeders).compareTo(_parseSeeders(a.seeders)),
        );
        break;
      case _CustomsSortOption.sizeDesc:
        filteredTorrents.sort(
          (a, b) =>
              _parseSizeInBytes(b.size).compareTo(_parseSizeInBytes(a.size)),
        );
        break;
      case _CustomsSortOption.nameAsc:
        filteredTorrents.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case _CustomsSortOption.none:
        break;
    }

    final bool hasTorrents = filteredTorrents.isNotEmpty;

    final customsState = context.watch<CustomsBloc>().state;
    final (selectedSourceIdx, selectedListingIdx) = customsState.maybeWhen(
      loaded: (_, _, srcIdx, _, _, listingIdx) => (srcIdx, listingIdx),
      orElse: () => (null, null),
    );

    PreferredSizeWidget appBar;
    if (_isSearching) {
      appBar = AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: context.appColors.appBarBackButtonIconColor,
          ),
          iconSize: 26,
          tooltip: "Close Search",
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
              _searchQuery = "";
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.amber, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Filter torrents by name...',
            hintStyle: TextStyle(
              fontSize: 16,
              color: context.appColors.searchBookmarksPlaceholderTextColor,
            ),
            border: InputBorder.none,
          ),
          onChanged: (text) {
            setState(() {
              _searchQuery = text.trim();
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                size: 22,
                color: context.appColors.searchBookmarksIconColor,
              ),
              tooltip: "Clear Text",
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = "";
                });
              },
            ),
        ],
      );
    } else {
      appBar = AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Custom Listings',
          style: TextStyle(
            color: context.appColors.appBarTextColor,
            letterSpacing: 2,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: 26,
              color: _searchQuery.isNotEmpty
                  ? context.appColors.bookmarksSidebarSelectedTileTextColor
                  : context.appColors.searchBookmarksIconColor,
            ),
            tooltip: "Filter / Search Torrents",
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          PopupMenuButton<_CustomsSortOption>(
            icon: Icon(
              _sortOption != _CustomsSortOption.none
                  ? Icons.filter_list_alt
                  : Icons.sort_rounded,
              size: 24,
              color: _sortOption != _CustomsSortOption.none
                  ? context.appColors.bookmarksSidebarSelectedTileTextColor
                  : context.appColors.settingsIconsColor,
            ),
            tooltip: "Sort / Order Torrents",
            color: context.appColors.aboutDialogBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (option) {
              setState(() {
                _sortOption = option;
              });
            },
            itemBuilder: (context) => [
              _buildSortMenuItem(
                context,
                _CustomsSortOption.none,
                "Default Order",
                Icons.format_list_numbered,
              ),
              _buildSortMenuItem(
                context,
                _CustomsSortOption.seedersDesc,
                "Most Seeders",
                Icons.arrow_upward_rounded,
              ),
              _buildSortMenuItem(
                context,
                _CustomsSortOption.sizeDesc,
                "Largest Size",
                Icons.data_usage_rounded,
              ),
              _buildSortMenuItem(
                context,
                _CustomsSortOption.nameAsc,
                "Name (A-Z)",
                Icons.sort_by_alpha_rounded,
              ),
            ],
          ),
          if (selectedSourceIdx != null && selectedListingIdx != null)
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                size: 24,
                color: context.appColors.settingsIconsColor,
              ),
              tooltip: "Refresh Listing",
              onPressed: () {
                context.read<CustomsTorrentsBloc>().add(
                  CustomsTorrentsEvent.searchCustomTorrents(
                    selectedSourceIndex: selectedSourceIdx,
                    selectedListingIndex: selectedListingIdx,
                  ),
                );
              },
            ),
        ],
      );
    }

    return Scaffold(
      appBar: appBar,
      floatingActionButton: FloatingActionsButtons(
        scrollToTop: true,
        enableAddTorrent: false,
        enableBookmarks: true,
        enableCustoms: true,
        enableSettings: true,
        activeScreen: ActiveScreen.customs,
        scrollController: _scrollController,
        hasTorrents: hasTorrents,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
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
                  const SizedBox(height: 16),

                  BlocBuilder<CustomsBloc, CustomsState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () => Center(
                          child: Text(
                            "No Custom Listings Loaded Yet...",
                            style: TextStyle(
                              color: context.appColors.generalTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressBarWidget()),
                        error: (String errorMessage) {
                          return Text(
                            "Error : $errorMessage",
                            style: TextStyle(
                              color: context.appColors.generalTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          );
                        },

                        loaded:
                            (
                              customListingSourceDetails,
                              selectedCustomSource,
                              selectedCustomSourceIndex,
                              selectedCustomSourceListings,
                              selectedCustomSourceListing,
                              selectedCustomListingIndex,
                            ) {
                              List<String> currentSourceListings = [];
                              if (selectedCustomSource != null) {
                                try {
                                  currentSourceListings =
                                      customListingSourceDetails
                                          .firstWhere(
                                            (element) =>
                                                element.customSourceName ==
                                                selectedCustomSource,
                                          )
                                          .customSourceListings;
                                } catch (e) {
                                  createSnackBar(
                                    message: "Error : ${e.toString()}",
                                    duration: 5,
                                  );
                                }
                              }
                              final sourceState =
                                  context.watch<SourceBloc>().state;
                              final visibleCustomSources =
                                  customListingSourceDetails.where((sourceDetail) {
                                if (sourceState.hideNsfw &&
                                    NsfwHelper.isNsfwSource(
                                      sourceDetail.customSourceName,
                                    )) {
                                  return false;
                                }
                                if (sourceState.disabledSources.contains(
                                  sourceDetail.customSourceName,
                                )) {
                                  return false;
                                }
                                return true;
                              }).map((s) => s.customSourceName).toList();

                              final selectedSourceValue =
                                  visibleCustomSources.contains(selectedCustomSource)
                                      ? selectedCustomSource
                                      : null;

                              final visibleListings = currentSourceListings.where((l) {
                                if (sourceState.hideNsfw &&
                                    NsfwHelper.isNsfwCategory(l)) {
                                  return false;
                                }
                                return true;
                              }).toList();

                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownWidget(
                                          hintText: "Select Source",
                                          items: visibleCustomSources,
                                          onChanged: (value) {
                                            if (value != null) {
                                              List<String> customSources =
                                                  customListingSourceDetails
                                                      .map(
                                                        (
                                                          sourceDetail,
                                                        ) => sourceDetail
                                                            .customSourceName,
                                                      )
                                                      .toList();

                                              int selectedSourceIndex =
                                                  customSources.indexOf(value);

                                              InternalCustomSourceDetails
                                              sourceDetail =
                                                  customListingSourceDetails
                                                      .firstWhere(
                                                        (sourceDetail) =>
                                                            sourceDetail
                                                                .customSourceName ==
                                                            value,
                                                      );

                                              context.read<CustomsBloc>().add(
                                                CustomsEvent.selectCustomSource(
                                                  selectedCustomSource: value,
                                                  selectedCustomSourceIndex:
                                                      selectedSourceIndex,
                                                  selectedCustomSourceListings:
                                                      sourceDetail
                                                          .customSourceListings,
                                                ),
                                              );
                                            }
                                          },
                                          selectedValue: selectedSourceValue,
                                        ),
                                      ),

                                      SizedBox(width: 5),

                                      if (visibleListings.isNotEmpty) ...[
                                        Expanded(
                                          child: DropdownWidget(
                                            hintText: "Select Listing",
                                            items: visibleListings,
                                            onChanged: (value) {
                                              _searchController.clear();
                                              setState(() {
                                                _searchQuery = "";
                                              });

                                              int selectedListingIndex =
                                                  currentSourceListings.indexOf(
                                                    value!,
                                                  );

                                              context.read<CustomsBloc>().add(
                                                CustomsEvent.selectCustomListing(
                                                  selectedListing: value,
                                                  selectedListingIndex:
                                                      selectedListingIndex,
                                                ),
                                              );

                                              context.read<CustomsTorrentsBloc>().add(
                                                CustomsTorrentsEvent.searchCustomTorrents(
                                                  selectedSourceIndex:
                                                      selectedCustomSourceIndex!,
                                                  selectedListingIndex:
                                                      selectedListingIndex,
                                                ),
                                              );
                                            },
                                            selectedValue:
                                                visibleListings.contains(
                                                  selectedCustomSourceListing,
                                                )
                                                ? selectedCustomSourceListing
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              );
                            },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<CustomsTorrentsBloc, CustomsTorrentsState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () => Text(
                          "Choose a Custom Listing...",
                          style: TextStyle(
                            color: context.appColors.generalTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        loading: () =>
                            const Center(child: CircularProgressBarWidget()),

                        error: (errorMessage) => Text(
                          "Error : $errorMessage",
                          style: TextStyle(
                            color: context.appColors.generalTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),

                        loaded: (torrentsList) {
                          if (torrentsList.isEmpty) {
                            return Center(
                              child: Text(
                                "No Torrents Found in this Listing...",
                                style: TextStyle(
                                  color: context.appColors.generalTextColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_searchQuery.isNotEmpty ||
                                  _sortOption != _CustomsSortOption.none)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 8.0,
                                    top: 4.0,
                                    left: 4.0,
                                    right: 4.0,
                                  ),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      if (_searchQuery.isNotEmpty)
                                        InputChip(
                                          visualDensity:
                                              VisualDensity.compact,
                                          label: Text(
                                            'Query: "$_searchQuery"',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context
                                                  .appColors
                                                  .bookmarksSidebarSelectedTileTextColor,
                                            ),
                                          ),
                                          backgroundColor: context
                                              .appColors
                                              .bookmarksSidebarSelectedTileBackgroundColor,
                                          deleteIconColor: context
                                              .appColors
                                              .bookmarksSidebarSelectedTileTextColor,
                                          onDeleted: () {
                                            setState(() {
                                              _searchController.clear();
                                              _searchQuery = "";
                                            });
                                          },
                                        ),
                                      if (_sortOption !=
                                          _CustomsSortOption.none)
                                        InputChip(
                                          visualDensity:
                                              VisualDensity.compact,
                                          label: Text(
                                            _sortOptionLabel(_sortOption),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context
                                                  .appColors
                                                  .bookmarksSidebarSelectedTileTextColor,
                                            ),
                                          ),
                                          backgroundColor: context
                                              .appColors
                                              .bookmarksSidebarSelectedTileBackgroundColor,
                                          deleteIconColor: context
                                              .appColors
                                              .bookmarksSidebarSelectedTileTextColor,
                                          onDeleted: () {
                                            setState(() {
                                              _sortOption =
                                                  _CustomsSortOption.none;
                                            });
                                          },
                                        ),
                                      Text(
                                        "${filteredTorrents.length} of ${torrentsList.length}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: context
                                              .appColors
                                              .cardSecondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (filteredTorrents.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 36.0,
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.search_off_rounded,
                                          size: 48,
                                          color: context
                                              .appColors
                                              .cardSecondaryTextColor
                                              .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "No torrents match '$_searchQuery'",
                                          style: TextStyle(
                                            color: context
                                                .appColors
                                                .generalTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 16,
                                          ),
                                          label:
                                              const Text("Clear filter"),
                                          onPressed: () {
                                            setState(() {
                                              _searchController.clear();
                                              _searchQuery = "";
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                TorrentListWidget(
                                  torrents: filteredTorrents,
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
