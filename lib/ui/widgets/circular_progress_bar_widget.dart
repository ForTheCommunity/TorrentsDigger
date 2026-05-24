import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/extensions.dart';

class CircularProgressBarWidget extends StatelessWidget {
  const CircularProgressBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: context.appColors.circularProgressIndicatorColor,
    );
  }
}
