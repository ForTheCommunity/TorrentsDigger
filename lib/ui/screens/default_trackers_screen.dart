import 'package:flutter/gestures.dart';
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: context.appColors.defaultTrackersInfoColor,
                    wordSpacing: 2.0,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Select a default trackers list.\nThese Trackers will be added to magnet links.\n'
                          'This can help in discovering more peers when downloading torrents.\n'
                          'If you are unsure about what types of trackers list to use.\n'
                          'You can use default Trackers List [ All Trackers ]\n'
                          'Trackers Lists are fetched from ',
                    ),
                    TextSpan(
                      text: 'https://github.com/ngosang/trackerslist#lists',
                      style: TextStyle(color: context.appColors.hyperlinkColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          openUrl(
                            urlType: UrlType.normalLink,
                            clipboardCopy: false,
                            url:
                                "https://github.com/ngosang/trackerslist#lists",
                          );
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<DefaultTrackersBloc, DefaultTrackersState>(
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
            ],
          ),
        ),
      ),
    );
  }
}
