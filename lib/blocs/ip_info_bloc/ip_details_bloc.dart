import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'ip_details_event.dart';
part 'ip_details_state.dart';
part 'ip_details_bloc.freezed.dart';

class IpDetailsBloc extends Bloc<IpDetailsEvent, IpDetailsState> {
  IpDetailsBloc() : super(const _Initial()) {
    on<_ExtractIpDetails>(_extractIpDetails);
  }

  void _extractIpDetails(
    _ExtractIpDetails event,
    Emitter<IpDetailsState> emit,
  ) async {
    emit(const IpDetailsState.inProgress());
    try {
      var ipDetails = await getIpDetails();
      emit(IpDetailsState.success(proxyIpInfo: ipDetails));
    } catch (e) {
      emit(IpDetailsState.failed(error: e.toString()));

      createSnackBar(message: e.toString(), duration: 10);
    }
  }
}
