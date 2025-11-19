import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/customs_bloc/customs_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/dropdown_widget.dart';
import 'package:torrents_digger/ui/widgets/torrent_list_widget.dart';

class CustomsScreen extends StatelessWidget {
  const CustomsScreen({super.key});

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
                        child: Text('No Custom Listings Loaded Yet...'),
                      ),
                      loading: () =>
                          Center(child: const CircularProgressBarWidget()),
                      loaded:
                          (
                            customDetails,
                            selectedCustomListing,
                            selectedCustomListingIndex,
                            torrentsList,
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
                                    context.read<CustomsBloc>().add(
                                      CustomsEvent.searchTorrents(),
                                    );
                                  }
                                },
                                selectedValue: selectedCustomListing,
                              ),
                              if (torrentsList != null)
                                TorrentListWidget(torrents: torrentsList),
                            ],
                          ),
                      error: (String errorMessage) {
                        return Text("Error : $errorMessage");
                      },
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
