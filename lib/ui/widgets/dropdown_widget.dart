import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';

class DropdownWidget extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final String hintText;
  final ValueChanged<String?> onChanged;

  const DropdownWidget({
    super.key,

    required this.items,
    required this.selectedValue,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // final effectiveValue = selectedValue ?? defaultValue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: context.appColors.sourcesDropdownBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            hintText,
            style: TextStyle(
              color: context.appColors.generalTextColor,
              wordSpacing: 3,
            ),
          ),
          value: selectedValue,
          isExpanded: true,
          style: TextStyle(
            color: context.appColors.generalTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.9,
          ),
          dropdownColor: context.appColors.sourcesDropdownOpenedBackgroundColor,

          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
