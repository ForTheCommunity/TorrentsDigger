import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'customs_torrents_event.dart';
part 'customs_torrents_state.dart';
part 'customs_torrents_bloc.freezed.dart';

class CustomsTorrentsBloc
    extends Bloc<CustomsTorrentsEvent, CustomsTorrentsState> {
  CustomsTorrentsBloc() : super(_Initial()) {
    on<_SearchTorrents>(_loadCustomTorrents);
  }

  Future<void> _loadCustomTorrents(
    _SearchTorrents event,
    Emitter<CustomsTorrentsState> emit,
  ) async {
    try {
      emit(CustomsTorrentsState.loading());

      final (torrents, _) = await digCustomTorrents(
        index: BigInt.from(event.selectedIndex),
      );
      emit(CustomsTorrentsState.loaded(torrents: torrents));
    } catch (e) {
      emit(CustomsTorrentsState.error(errorMessage: e.toString()));
      createSnackBar(
        message: "Error searching torrents: ${e.toString()}",
        duration: 5,
      );
    }
  }
}
