import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';

class CircularProgressBarWidget extends StatelessWidget {
  const CircularProgressBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: AppColors.greenColor);
  }
}
