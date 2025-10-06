part of 'source_bloc.dart';

@freezed
abstract class SourceState with _$SourceState {
  const SourceState._();

  const factory SourceState({
    required Map<String, InternalSourceDetails> sources,
    String? selectedSource,
    String? selectedCategory,
    String? selectedFilter,
    String? selectedSorting,
  }) = _SourceState;

  InternalSourceDetails? get selectedDetails =>
      selectedSource != null ? sources[selectedSource] : null;
}
