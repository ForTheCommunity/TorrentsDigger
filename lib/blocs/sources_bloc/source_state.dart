part of 'source_bloc.dart';

@freezed
abstract class SourceState with _$SourceState {
  const SourceState._();

  const factory SourceState({
    // This annotation tells the app: "Do NOT save the list of sources to the disk".
    // We want to load fresh source details from the rust-side every time the app starts.
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default([])
    List<InternalSource> sources,
    String? selectedSource,
    String? selectedCategory,
    String? selectedFilter,
    String? selectedSorting,
    String? selectedSortingOrder,

    // This holds the memory of selectedCategory, selectedFilter, selectedSorting,
    // selectedSortingOrder for ALL sources, not just the active one.
    @Default({}) Map<String, SourceStateHydration> savedSelectedSourceData,
  }) = _SourceState;

  // This enables the entire state (including the savedSelectedSourceData map)
  // to be loaded from hive database/box by HydratedBloc.
  factory SourceState.fromJson(Map<String, dynamic> json) =>
      _$SourceStateFromJson(json);

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

// Source State Hydration
@freezed
abstract class SourceStateHydration with _$SourceStateHydration {
  // defining constructor with fields that we need to hydrate.
  const factory SourceStateHydration({
    String? selectedCategory,
    String? selectedFilter,
    String? selectedSorting,
    String? selectedSortingOrder,
  }) = _SourceStateHydration;

  // This allows this object to be created from
  // JSON data that is saved in a hive database/box by HydratedBloc.
  factory SourceStateHydration.fromJson(Map<String, dynamic> json) =>
      _$SourceStateHydrationFromJson(json);
}
