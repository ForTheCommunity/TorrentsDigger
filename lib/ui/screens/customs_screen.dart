import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/customs_bloc/customs_dropdown_bloc/customs_bloc.dart';
import 'package:torrents_digger/blocs/customs_bloc/customs_torrents/customs_torrents_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/dropdown_widget.dart';
import 'package:torrents_digger/ui/widgets/torrent_list_widget.dart';

class CustomsScreen extends StatefulWidget {
  const CustomsScreen({super.key});

  @override
  State<CustomsScreen> createState() => _CustomsScreenState();
}

class _CustomsScreenState extends State<CustomsScreen> {
  late final CustomsTorrentsBloc _customsTorrentsBloc;

  @override
  void initState() {
    super.initState();
    _customsTorrentsBloc = context.read<CustomsTorrentsBloc>();
  }

  @override
  void dispose() {
    _customsTorrentsBloc.add(const CustomsTorrentsEvent.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Custom Listings',
          style: TextStyle(
            color: AppColors.greenColor,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 7.0),
            child: Column(
              children: [
                const SizedBox(height: 16),

                BlocBuilder<CustomsBloc, CustomsState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => const Center(
                        child: Text("No Custom Listings Loaded Yet..."),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressBarWidget()),
                      error: (String errorMessage) {
                        return Text("Error : $errorMessage");
                      },

                      loaded:
                          (
                            customDetails,
                            selectedCustomListing,
                            selectedCustomListingIndex,
                          ) => Column(
                            children: [
                              DropdownWidget(
                                hintText: "Select Custom Listing",
                                items: customDetails,
                                onChanged: (value) {
                                  if (value != null) {
                                    final int selectedIndex = customDetails
                                        .indexOf(value);

                                    context.read<CustomsBloc>().add(
                                      CustomsEvent.selectCustomListing(
                                        selectedListing: value,
                                        selectedIndex: selectedIndex,
                                      ),
                                    );

                                    context.read<CustomsTorrentsBloc>().add(
                                      CustomsTorrentsEvent.searchCustomTorrents(
                                        selectedIndex: selectedIndex,
                                      ),
                                    );
                                  }
                                },
                                selectedValue: selectedCustomListing,
                              ),
                            ],
                          ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<CustomsTorrentsBloc, CustomsTorrentsState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => Text(
                        "Choose a Custom Listing...",
                        style: TextStyle(color: AppColors.greenColor),
                      ),

                      loading: () =>
                          const Center(child: CircularProgressBarWidget()),

                      error: (errorMessage) => Text("Error : $errorMessage"),

                      loaded: (torrentsList) =>
                          TorrentListWidget(torrents: torrentsList),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
