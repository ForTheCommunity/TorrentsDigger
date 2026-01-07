import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/get_source_details_data.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

part 'source_bloc.freezed.dart';
part 'source_bloc.g.dart';
part 'source_events.dart';
part 'source_state.dart';

class SourceBloc extends HydratedBloc<SourceWidgetEvents, SourceState> {
  SourceBloc() : super(SourceState(sources: [])) {
    on<LoadSources>(_onLoadSources);
    on<SelectSource>(_onSelectSource);
    on<SelectCategory>(_onSelectCategory);
    on<SelectFilter>(_onSelectFilter);
    on<SelectSorting>(_onSelectSorting);
    on<SelectSortingOrder>(_onSelectSortingOrder);
  }

  Future<void> _onLoadSources(
    LoadSources event,
    Emitter<SourceState> emit,
  ) async {
    final data = await initialSourceDetailsData();
    emit(state.copyWith(sources: data));
  }

  void _onSelectSource(SelectSource event, Emitter<SourceState> emit) {
    // Checking if this newly selected source is in savedSelectedSourceData Map.
    SourceStateHydration? savedSelectedSourceData =
        state.savedSelectedSourceData[event.selectedSource];
    emit(
      state.copyWith(
        selectedSource: event.selectedSource,
        // Hydrating Saved Source Data or resetting to null if none exist
        selectedCategory: savedSelectedSourceData?.selectedCategory,
        selectedFilter: savedSelectedSourceData?.selectedFilter,
        selectedSorting: savedSelectedSourceData?.selectedSorting,
        selectedSortingOrder: savedSelectedSourceData?.selectedSortingOrder,
      ),
    );
  }

  void _onSelectCategory(SelectCategory event, Emitter<SourceState> emit) {
    emit(
      _updateSavedSourceData(state.copyWith(selectedCategory: event.category)),
    );
  }

  void _onSelectFilter(SelectFilter event, Emitter<SourceState> emit) {
    emit(_updateSavedSourceData(state.copyWith(selectedFilter: event.filter)));
  }

  void _onSelectSorting(SelectSorting event, Emitter<SourceState> emit) {
    emit(
      _updateSavedSourceData(state.copyWith(selectedSorting: event.sorting)),
    );
  }

  void _onSelectSortingOrder(
    SelectSortingOrder event,
    Emitter<SourceState> emit,
  ) {
    emit(
      _updateSavedSourceData(
        state.copyWith(selectedSortingOrder: event.sortingOder),
      ),
    );
  }

  SourceState _updateSavedSourceData(SourceState state) {
    // if no source is selected, we can't save any data.
    if (state.selectedSource == null) return state;

    // getting existing data for this source
    // or create a new blank one if it is new;
    final currentSavedSourceData =
        state.savedSelectedSourceData[state.selectedSource!] ??
        const SourceStateHydration();

    // new config object that combines the old config with the
    // currently selected values in the state.
    final newSourceData = currentSavedSourceData.copyWith(
      selectedCategory: state.selectedCategory,
      selectedFilter: state.selectedFilter,
      selectedSorting: state.selectedSorting,
      selectedSortingOrder: state.selectedSortingOrder,
    );

    // a copy of the main map so we can modify it.
    final newSavedSourceData = Map<String, SourceStateHydration>.from(
      state.savedSelectedSourceData,
    );

    // updating
    newSavedSourceData[state.selectedSource!] = newSourceData;

    // Returning the state with the updated map.
    // Because the state changed, HydratedBloc will automatically save this to Hive Database/Box.
    return state.copyWith(savedSelectedSourceData: newSavedSourceData);
  }

  @override
  SourceState? fromJson(Map<String, dynamic> json) =>
      SourceState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(SourceState state) => state.toJson();
}
