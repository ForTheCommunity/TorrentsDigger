part of 'source_bloc.dart';

class SourceState {
  final Map<String, InternalSourceDetails> sources;
  final String? selectedSource;
  final String? selectedCategory;
  final String? selectedFilter;
  final String? selectedSorting;

  SourceState({
    required this.sources,
    this.selectedSource,
    this.selectedCategory,
    this.selectedFilter,
    this.selectedSorting,
  });

  InternalSourceDetails? get selectedDetails =>
      selectedSource != null ? sources[selectedSource] : null;

  SourceState copyWith({
    Map<String, InternalSourceDetails>? sources,
    String? selectedSource,
    String? selectedCategory,
    String? selectedFilter,
    String? selectedSorting,
  }) {
    return SourceState(
      sources: sources ?? this.sources,
      selectedSource: selectedSource ?? this.selectedSource,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedSorting: selectedSorting ?? this.selectedSorting,
    );
  }
}
