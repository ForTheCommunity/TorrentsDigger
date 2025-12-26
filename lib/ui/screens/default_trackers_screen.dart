import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/default_trackers_bloc/default_trackers_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/launch_url.dart';

class DefaultTrackersScreen extends StatelessWidget {
  const DefaultTrackersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Default Trackers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info,
              color: context.appColors.defaultTrackersInfoIconColor,
            ),
            onPressed: () {
              _defaultTrackersInfo(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 15),
          SingleChildScrollView(
            child: BlocBuilder<DefaultTrackersBloc, DefaultTrackersState>(
              builder: (context, state) {
                return state.when(
                  initial: () => Center(
                    child: Text(
                      'No Trackers List Loaded Yet...',
                      style: TextStyle(
                        color: context.appColors.generalTextColor,
                      ),
                    ),
                  ),
                  loading: () => const CircularProgressBarWidget(),
                  loaded: (trackersList, activatedDefaultTrackersList) =>
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: trackersList.length,
                        itemBuilder: (context, index) {
                          final tracker = trackersList[index];
                          final trackerId = tracker.$1;
                          final trackerName = tracker.$2;
                          return ListTile(
                            title: Row(
                              children: [
                                activatedDefaultTrackersList == trackerId
                                    ? Icon(
                                        Icons.device_hub,
                                        size: 27,
                                        color: context
                                            .appColors
                                            .activeTrackersListIconColor,
                                      )
                                    : Icon(
                                        Icons.device_hub,
                                        color: context
                                            .appColors
                                            .defaultTrackersIconColor,
                                      ),
                                SizedBox(width: 10),
                                Text(
                                  trackerName,
                                  style: TextStyle(
                                    color: context
                                        .appColors
                                        .defaultTrackersTextColor,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              context.read<DefaultTrackersBloc>().add(
                                DefaultTrackersEvent.setTrackersList(
                                  selectedTrackerId: trackerId,
                                ),
                              );
                            },
                          );
                        },
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _defaultTrackersInfo(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        // title: const Text("Default Trackers Info"),
        backgroundColor:
            context.appColors.defaultTrackersInfoDialogBackgroundColor,
        actionsAlignment: MainAxisAlignment.start,
        content: SingleChildScrollView(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: context.appColors.defaultTrackersInfoColor,
                wordSpacing: 2.0,
              ),
              children: [
                const TextSpan(
                  text:
                      'Select a default trackers list.\nThese Trackers will be added to magnet links. '
                      'This can help in discovering more peers when downloading torrents. '
                      'If you are unsure about what types of trackers list to use. '
                      'You can use default Trackers List [ All Trackers ] '
                      'Trackers Lists are fetched from ',
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () async {
                      openUrl(
                        urlType: UrlType.normalLink,
                        clipboardCopy: false,
                        url: "https://github.com/ngosang/trackerslist#lists",
                      );
                    },
                    child: Text(
                      'https://github.com/ngosang/trackerslist#lists',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.appColors.hyperlinkColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: context
                  .appColors
                  .defaultTrackersInfoDialogCloseTextButtonBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Close",
              style: TextStyle(
                color:
                    context.appColors.defaultTrackersInfoDialogCloseTextColor,
              ),
            ),
          ),
        ],
      );
    },
  );
}
