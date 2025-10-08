import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_event.dart';
part 'pagination_state.dart';
part 'pagination_bloc.freezed.dart';

class PaginationBloc extends Bloc<PaginationEvent, PaginationState> {
  PaginationBloc() : super(_Initial()) {
    on<PaginationEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
