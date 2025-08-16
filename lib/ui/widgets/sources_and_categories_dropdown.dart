import 'package:flutter/material.dart';
import 'package:torrents_digger/configs/colors.dart';

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
        Expanded(child: _buildSourcesDropdown()),
        const SizedBox(width: 16),
        Expanded(child: _buildCategoriesDropdown()),
      ],
    );
  }

  // Source Dropdown Widget
  Widget _buildSourcesDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.sourcesDropdownBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSource,
          isExpanded: true,
          style: const TextStyle(
            color: AppColors.greenColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.9,
          ),
          dropdownColor: AppColors.sourcesDropdownOpenedBackgroundColor,
          onChanged: onSourceChanged,
          items: categoryMap.keys.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  // Categories Dropdown Widget
  Widget _buildCategoriesDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.categoriesDropdownBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          style: const TextStyle(
            color: AppColors.greenColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.9,
          ),
          dropdownColor: AppColors.categoriesDropdownOpenedBackgroundColor,
          onChanged: onCategoryChanged,
          items: categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }
}

// works perfectly

// import 'package:flutter/material.dart';
// import 'package:torrents_digger/configs/colors.dart';

// class SourcesAndCategoriesDropdown extends StatefulWidget {
//   const SourcesAndCategoriesDropdown({super.key});

//   @override
//   State<SourcesAndCategoriesDropdown> createState() =>
//       _SourcesAndCategoriesDropdownState();
// }

// class _SourcesAndCategoriesDropdownState
//     extends State<SourcesAndCategoriesDropdown> {
//   String? _selectedSource;
//   String? _selectedCategory;
//   List<String> _categories = [];

//   // Sample data for categories and their sub-categories
//   final Map<String, List<String>> _categoryMap = {
//     "Nyaa": [
//       "All Categories",
//       "Anime",
//       "Anime Music Video",
//       "Anime English Translated",
//       "Anime Non English Translated",
//       "Anime Raw",
//       "Audio",
//       "Audio Lossless",
//       "Audio Lossy",
//       "Literature",
//       "Literature English Translated",
//       "Literature Non English Translated",
//       "Literature Raw",
//       "Live Action",
//       "Live Action English Translated",
//       "Live Action Idol Promotional Video",
//       "Live Action Non English Translated",
//       "Live Action Raw",
//       "Pictures",
//       "Pictures Graphics",
//       "Pictures Photos",
//       "Software",
//       "Software Applications",
//       "Software Games",
//     ],
//     'Movies': ['Action', 'Comedy', 'Horror', 'Sci-Fi'],
//     'TV Shows': ['Drama', 'Comedy', 'Animated'],
//     'Music': ['Pop', 'Rock', 'Electronic', 'Classical'],
//     'Games': ['Adventure', 'RPG', 'Strategy', 'Simulation'],
//     'Software': ['Operating Systems', 'Applications', 'Utilities'],
//   };

//   @override
//   void initState() {
//     // setting initial values for the dropdowns
//     _selectedSource = _categoryMap.keys.first;
//     _updateCategories();
//   }

//   // method to update the list of categories
//   void _updateCategories() {
//     setState(() {
//       _categories = _categoryMap[_selectedSource] ?? [];
//       _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(child: _buildSourcesDropdown()),
//         const SizedBox(width: 15),
//         Expanded(child: _buildCategoriesDropdown()),
//       ],
//     );
//   }

//   // Source Dropdown Widget
//   Widget _buildSourcesDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       decoration: BoxDecoration(
//         color: AppColors.sourcesDropdownBackgroundColor,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedSource,
//           isExpanded: true,
//           style: const TextStyle(
//             color: AppColors.greenColor,
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.9,
//           ),
//           dropdownColor: AppColors.sourcesDropdownOpenedBackgroundColor,
//           onChanged: (String? newValue) {
//             setState(() {
//               _selectedSource = newValue;
//               _updateCategories();
//             });
//           },
//           items: _categoryMap.keys.map<DropdownMenuItem<String>>((
//             String value,
//           ) {
//             return DropdownMenuItem<String>(value: value, child: Text(value));
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   // Categories Dropdown Widget
//   Widget _buildCategoriesDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       decoration: BoxDecoration(
//         color: AppColors.categoriesDropdownBackgroundColor,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedCategory,
//           isExpanded: true,
//           style: const TextStyle(
//             color: AppColors.greenColor,
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.9,
//           ),
//           dropdownColor: AppColors.categoriesDropdownOpenedBackgroundColor,
//           onChanged: (String? newValue) {
//             setState(() {
//               _selectedCategory = newValue;
//             });
//           },
//           items: _categories.map<DropdownMenuItem<String>>((String value) {
//             return DropdownMenuItem<String>(value: value, child: Text(value));
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
