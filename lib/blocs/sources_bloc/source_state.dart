part of 'source_bloc.dart';

@freezed
abstract class SourceState with _$SourceState {
  const SourceState._();

  const factory SourceState({
    required List<InternalSource> sources,
    String? selectedSource,
    String? selectedCategory,
    String? selectedFilter,
    String? selectedSorting,
    String? selectedSortingOrder,
  }) = _SourceState;

  InternalSourceDetails? get selectedDetails {
    if (selectedSource == null) {
      return null;
    }

    for (InternalSource source in sources) {
      if (source.sourceName == selectedSource) {
        return source.sourceDetails;
      }
    }
    return null;
  }
}
