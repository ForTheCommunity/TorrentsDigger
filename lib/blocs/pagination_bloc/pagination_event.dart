part of 'pagination_bloc.dart';

@immutable
sealed class PaginationEvent {}

class SetNextPage extends PaginationEvent {
  final int nextPage;
  SetNextPage(this.nextPage);
}

class ResetPagination extends PaginationEvent {}

class SetPreviousPages extends PaginationEvent {
  final int page;
  SetPreviousPages(this.page);
}

class ClearPreviousPages extends PaginationEvent {}
