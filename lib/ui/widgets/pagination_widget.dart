import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';

class PaginationWidget extends StatelessWidget {
  const PaginationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {},
          child: Icon(
            Icons.keyboard_arrow_left,
            color: AppColors.greenColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(width: 20),
        Text("1"),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {},
          child: Icon(
            Icons.keyboard_arrow_right,
            color: AppColors.greenColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
