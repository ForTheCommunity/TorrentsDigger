import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';

class SourcesAndCategoriesDropdown extends StatelessWidget {
  const SourcesAndCategoriesDropdown({
    super.key,
    required this.selectedSource,
    required this.selectedCategory,
    required this.categories,
    required this.onSourceChanged,
    required this.onCategoryChanged,
    required this.categoryMap,
  });

  final String? selectedSource;
  final String? selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onSourceChanged;
  final ValueChanged<String?> onCategoryChanged;
  final Map<String, List<String>> categoryMap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Source',
                style: TextStyle(
                  color: context.appColors.sourceLabelColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              _buildSourcesDropdown(context),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Category',
                style: TextStyle(
                  color: context.appColors.categoryLabelColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              _buildCategoriesDropdown(context),
            ],
          ),
        ),
      ],
    );
  }

  // Source Dropdown Widget
  Widget _buildSourcesDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: context.appColors.sourcesDropdownBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSource,
          isExpanded: true,
          style: TextStyle(
            color: context.appColors.generalTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.9,
          ),
          dropdownColor: context.appColors.sourcesDropdownOpenedBackgroundColor,
          onChanged: onSourceChanged,
          items: categoryMap.keys.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  // Categories Dropdown Widget
  Widget _buildCategoriesDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: context.appColors.categoriesDropdownBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          style: TextStyle(
            color: context.appColors.generalTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.9,
          ),
          dropdownColor:
              context.appColors.categoriesDropdownOpenedBackgroundColor,
          onChanged: onCategoryChanged,
          items: categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }
}
