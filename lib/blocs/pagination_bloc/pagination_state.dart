part of 'pagination_bloc.dart';

@freezed
class PaginationState with _$PaginationState {
  const factory PaginationState.initial() = _Initial;
  const factory PaginationState.loading() = _Loading;
  const factory PaginationState.loaded({
    required InternalPagination pagination,
  }) = _Loaded;
  const factory PaginationState.error({required String error}) = _Error;
}
