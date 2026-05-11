import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/custom_dns_bloc/custom_dns_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

class CustomDnsScreen extends StatelessWidget {
  const CustomDnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DNS Settings'),
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
              _dnsInfo(context);
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: BlocBuilder<CustomDnsBloc, CustomDnsState>(
          builder: (context, state) {
            return state.when(
              initial: () => Text("Initial"),
              loading: () => const CircularProgressBarWidget(),
              loaded: (customDNSResolvers, activeCustomDnsResolver) =>
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customDNSResolvers.length,
                    itemBuilder: (context, index) {
                      final dnsResolver = customDNSResolvers[index];
                      final dnsResolverID = dnsResolver.index;
                      final dnsResolverName = dnsResolver.name;
                      return ListTile(
                        title: Row(
                          children: [
                            activeCustomDnsResolver == dnsResolverID
                                ? Icon(
                                    Icons.network_ping,
                                    size: 27,
                                    color: context
                                        .appColors
                                        .activeTrackersListIconColor,
                                  )
                                : Icon(
                                    Icons.network_ping,
                                    color: context
                                        .appColors
                                        .defaultTrackersIconColor,
                                  ),

                            SizedBox(width: 10),

                            Text(
                              dnsResolverName,
                              style: TextStyle(
                                color:
                                    context.appColors.defaultTrackersTextColor,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          createSnackBar(message: "TODO", duration: 2);
                        },
                      );
                    },
                  ),
            );
          },
        ),
      ),
    );
  }
}

void _dnsInfo(BuildContext context) {
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
                      'Select a DNS Provider.\n'
                      'This can unblock some sources which may be blocked by default DNS '
                      'setted by Router, ISP or Network Admin.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    color: context
                        .appColors
                        .defaultTrackersInfoDialogCloseTextColor,
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
