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

class CustomsScreen extends StatefulWidget {
  const CustomsScreen({super.key});

  @override
  State<CustomsScreen> createState() => _CustomsScreenState();
}

class _CustomsScreenState extends State<CustomsScreen> {
  late final CustomsTorrentsBloc _customsTorrentsBloc;
  late final CustomsBloc _customsBloc;

  @override
  void initState() {
    super.initState();
    _customsTorrentsBloc = context.read<CustomsTorrentsBloc>();
    _customsBloc = context.read<CustomsBloc>();
  }

  @override
  void dispose() {
    _customsTorrentsBloc.add(const CustomsTorrentsEvent.reset());
    _customsBloc.add(const CustomsEvent.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Custom Listings',
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
      ),
      floatingActionButton: FloatingActionsButtons(
        scrollToTop: true,
        enableAddTorrent: false,
        enableBookmarks: true,
        enableCustoms: false,
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

                        loaded: (torrentsList) =>
                            TorrentListWidget(torrents: torrentsList),
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
