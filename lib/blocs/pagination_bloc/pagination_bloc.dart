import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_event.dart';
part 'pagination_state.dart';

class PaginationBloc extends Bloc<PaginationEvent, PaginationState> {
  PaginationBloc() : super(PaginationState()) {
    on<SetNextPage>((event, emit) {
      emit(PaginationState(nextPage: event.nextPage));
    });

    on<ResetPagination>((event, emit) {
      emit(PaginationState(nextPage: 1));
    });
  }
}
