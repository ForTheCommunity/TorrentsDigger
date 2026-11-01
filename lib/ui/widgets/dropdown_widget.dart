import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/extensions.dart';

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
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: context.appColors.sourcesDropdownBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: context.appColors.dropdownArrowDownColor.withValues(
            alpha: 0.25,
          ),
          width: 1,
        ),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            hintText,
            style: TextStyle(
              color: context.appColors.generalTextColor,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          value: selectedValue,
          isExpanded: true,
          style: TextStyle(
            color: context.appColors.generalTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          dropdownColor: context.appColors.sourcesDropdownOpenedBackgroundColor,
          iconEnabledColor: context.appColors.dropdownArrowDownColor,

          selectedItemBuilder: (BuildContext context) {
            return items.map((String item) {
              return Align(
                alignment: Alignment.centerLeft,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth,
                        ),
                        child: Text(
                          item,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.appColors.generalTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            height: 1.15,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList();
          },

          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.appColors.generalTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
