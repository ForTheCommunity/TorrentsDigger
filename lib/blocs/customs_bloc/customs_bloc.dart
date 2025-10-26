import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'customs_event.dart';
part 'customs_state.dart';
part 'customs_bloc.freezed.dart';

class CustomsBloc extends Bloc<CustomsEvent, CustomsState> {
  CustomsBloc() : super(_Initial()) {
    on<_LoadCustoms>(_loadCustoms);
    on<_SelectCustomListing>(_selectCustomListing);
    on<_SearchTorrents>(_searchTorrents);
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
          currentState.copyWith(selectedCustomListing: event.selectedListing),
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

  Future<void> _searchTorrents(
    _SearchTorrents event,
    Emitter<CustomsState> emit,
  ) async {
    final currentState = state;
    if (currentState is _Loaded && currentState.selectedCustomListing != null) {
      emit(CustomsState.loading());
      try {
        final (torrents, _) = await digCustomTorrents(
          custom: currentState.selectedCustomListing!,
        );

        emit(currentState.copyWith(torrentsList: torrents));
      } catch (e) {
        emit(CustomsState.error(errorMessage: e.toString()));
        createSnackBar(
          message: "Error searching torrents: ${e.toString()}",
          duration: 5,
        );
      }
    }
  }
}
