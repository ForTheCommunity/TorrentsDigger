import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/default_trackers_bloc/default_trackers_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';
import 'package:url_launcher/url_launcher.dart';

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
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          'Select a default tracker list. These Trackers will be added to magnet links.\n'
                          'This can help in discovering more peers when downloading torrents.\n'
                          'You can use default [All Trackers] '
                          'if you are unsure about what types of tracker list to use.\n'
                          'Trackers List are fetched from ',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    TextSpan(
                      text: 'https://github.com/ngosang/trackerslist#lists',
                      style: TextStyle(
                        color: AppColors.hyperlinkColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          Uri url = Uri.parse(
                            "https://github.com/ngosang/trackerslist#lists",
                          );
                          if (!await launchUrl(url)) {
                            createSnackBar(
                              message: 'Unable to open Link.',
                              duration: 2,
                            );
                          }
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<DefaultTrackersBloc, DefaultTrackersState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const Center(
                      child: Text('No Trackers List Loaded Yet...'),
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
                                  Text(trackerName),
                                  SizedBox(width: 15),
                                  activatedDefaultTrackersList == trackerId
                                      ? const Icon(
                                          Icons.check,
                                          color: AppColors.greenColor,
                                          size: 30,
                                        )
                                      : const SizedBox.shrink(),
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
