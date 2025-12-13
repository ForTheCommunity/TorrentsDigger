import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/ip_info_bloc/ip_details_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';

class IpDetailsWidget extends StatelessWidget {
  const IpDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<IpDetailsBloc, IpDetailsState>(
          builder: (context, testState) {
            return testState.when(
              initial: () => const Text("Testing proxy..."),
              inProgress: () => const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressBarWidget(),
              ),
              success: (String ipAddr) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "IP Address : ",
                      style: TextStyle(color: AppColors.greenColor),
                    ),
                    Text(ipAddr, style: TextStyle(color: AppColors.greenColor)),
                  ],
                );
              },
              failed: (String error) => Text(error),
            );
          },
        ),
      ],
    );
  }
}
