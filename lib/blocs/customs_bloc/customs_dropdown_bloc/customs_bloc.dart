import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'customs_event.dart';
part 'customs_state.dart';
part 'customs_bloc.freezed.dart';

class CustomsBloc extends Bloc<CustomsEvent, CustomsState> {
  CustomsBloc() : super(_Initial()) {
    on<_LoadCustoms>(_loadCustoms);
    on<_SelectCustomListing>(_selectCustomListing);
    on<_Reset>(_reset);
  }

  void _loadCustoms(_LoadCustoms event, Emitter<CustomsState> emit) async {
    emit(CustomsState.loading());
    try {
      var customsDetails = await getCustomsDetails();
      emit(CustomsState.loaded(customsDetails: customsDetails));
    } catch (e) {
      emit(CustomsState.error(errorMessage: e.toString()));
      createSnackBar(
        message: "Error Loading Customs Details : ${e.toString} ",
        duration: 5,
      );
    }
  }

  void _selectCustomListing(
    _SelectCustomListing event,
    Emitter<CustomsState> emit,
  ) async {
    final currentState = state;
    if (currentState is _Loaded) {
      try {
        emit(
          currentState.copyWith(
            selectedCustomListing: event.selectedListing,
            selectedCustomListingIndex: event.selectedIndex,
          ),
        );
      } catch (e) {
        emit(CustomsState.error(errorMessage: e.toString()));
        createSnackBar(
          message: "Error selecting Custom Listing : ${e.toString()}",
          duration: 5,
        );
      }
    }
  }

  void _reset(_Reset event, Emitter<CustomsState> emit) {
    final currentState = state;
    if (currentState is _Loaded) {
      emit(
        currentState.copyWith(
          selectedCustomListing: null,
          selectedCustomListingIndex: null,
        ),
      );
    }
  }
}
