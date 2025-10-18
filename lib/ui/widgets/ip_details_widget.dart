import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/ip_info_bloc/ip_details_bloc.dart';
import 'package:torrents_digger/configs/colors.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
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
              success: (InternalIpDetails ipDetails) {
                return Column(
                  children: [
                    IpDetailsTextWidget(
                      name: "IP Address",
                      value: ipDetails.ipAddr,
                    ),
                    IpDetailsTextWidget(name: "ISP", value: ipDetails.isp),
                    IpDetailsTextWidget(
                      name: "VPN",
                      value: ipDetails.isVpn.toString(),
                    ),
                    IpDetailsTextWidget(
                      name: "TOR",
                      value: ipDetails.isTor.toString(),
                    ),
                    IpDetailsTextWidget(
                      name: "Continent",
                      value: ipDetails.continent,
                    ),
                    IpDetailsTextWidget(
                      name: "Country",
                      value: _decodeUnicodeFlag(
                        "${ipDetails.country} ${ipDetails.flagUnicode}",
                      ),
                    ),
                    IpDetailsTextWidget(
                      name: "Region",
                      value: ipDetails.region,
                    ),
                    IpDetailsTextWidget(
                      name: "Capital",
                      value: ipDetails.capital,
                    ),
                    IpDetailsTextWidget(name: "City", value: ipDetails.city),
                    IpDetailsTextWidget(
                      name: "Latitude",
                      value: ipDetails.latitude.toString(),
                    ),
                    IpDetailsTextWidget(
                      name: "Longitude",
                      value: ipDetails.longitude.toString(),
                    ),
                    IpDetailsTextWidget(
                      name: "Timezone",
                      value: ipDetails.timezone,
                    ),
                    SizedBox(height: 30),
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

class IpDetailsTextWidget extends StatelessWidget {
  final String name;
  final String value;
  const IpDetailsTextWidget({
    super.key,
    required this.name,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$name : ",
            style: TextStyle(color: AppColors.greenColor, fontSize: 15),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: AppColors.magnetIconColor,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

String _decodeUnicodeFlag(String value) {
  final regex = RegExp(r'(U\+[0-9A-Fa-f]+(?:\sU\+[0-9A-Fa-f]+)*)');
  final match = regex.firstMatch(value);

  if (match != null) {
    // Extracting the Unicode part
    final unicodePart = match.group(0)!;

    // Converting it to emoji
    final codePoints = RegExp(r'U\+([0-9A-Fa-f]+)')
        .allMatches(unicodePart)
        .map((m) => int.parse(m.group(1)!, radix: 16))
        .toList();

    final flag = String.fromCharCodes(codePoints);

    // Replacing only the Unicode part with the emoji
    return value.replaceAll(unicodePart, flag);
  }
  return value;
}
