import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

part 'pagination_event.dart';
part 'pagination_state.dart';
part 'pagination_bloc.freezed.dart';

class PaginationBloc extends Bloc<PaginationEvent, PaginationState> {
  PaginationBloc() : super(_Initial()) {
    on<_InitPagination>(_initPagination);
    on<_ResetPagination>(_resetPagination);
  }

  void _initPagination(_InitPagination event, Emitter<PaginationState> emit) {
    emit(PaginationState.loading());
    emit(PaginationState.loaded(pagination: event.pagination));
  }

  void _resetPagination(_ResetPagination event, Emitter<PaginationState> emit) {
    emit(
      PaginationState.loaded(
        pagination: InternalPagination(
          currentPage: null,
          previousPage: null,
          nextPage: null,
        ),
      ),
    );
    emit(PaginationState.initial());
  }
}
