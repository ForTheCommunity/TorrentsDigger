part of 'pagination_bloc.dart';

@freezed
class PaginationEvent with _$PaginationEvent {
  const factory PaginationEvent.initPagination({
    required InternalPagination pagination,
  }) = _InitPagination;
  const factory PaginationEvent.resetPagination() = _ResetPagination;
}
