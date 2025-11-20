import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';
import 'package:torrents_digger/blocs/sources_bloc/get_source_details_data.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

part 'source_bloc.freezed.dart';
part 'source_events.dart';
part 'source_state.dart';

class SourceBloc extends Bloc<SourceWidgetEvents, SourceState> {
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
    emit(
      state.copyWith(
        selectedSource: event.selectedSource,
        // resetting category , filter , sorting values when source changes
        selectedCategory: null,
        selectedFilter: null,
        selectedSorting: null,
        selectedSortingOrder: null,
      ),
    );
  }

  void _onSelectCategory(SelectCategory event, Emitter<SourceState> emit) {
    emit(state.copyWith(selectedCategory: event.category));
  }

  void _onSelectFilter(SelectFilter event, Emitter<SourceState> emit) {
    emit(state.copyWith(selectedFilter: event.filter));
  }

  void _onSelectSorting(SelectSorting event, Emitter<SourceState> emit) {
    emit(state.copyWith(selectedSorting: event.sorting));
  }

  void _onSelectSortingOrder(
    SelectSortingOrder event,
    Emitter<SourceState> emit,
  ) {
    emit(state.copyWith(selectedSortingOrder: event.sortingOder));
  }
}
