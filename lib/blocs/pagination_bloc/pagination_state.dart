part of 'pagination_bloc.dart';

class PaginationState {
  int? nextPage;

  PaginationState({this.nextPage});

  copyWith(int? nextPage) {
    return PaginationState(nextPage: nextPage ?? this.nextPage);
  }
}
