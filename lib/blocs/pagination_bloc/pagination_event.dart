part of 'pagination_bloc.dart';

@freezed
class PaginationEvent with _$PaginationEvent {
  const factory PaginationEvent.started() = _Started;
}