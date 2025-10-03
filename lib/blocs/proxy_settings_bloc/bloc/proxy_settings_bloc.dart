import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:torrents_digger/src/rust/api/database/proxy.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'proxy_settings_event.dart';
part 'proxy_settings_state.dart';

class ProxySettingsBloc extends Bloc<ProxySettingsEvents, ProxySettingsState> {
  ProxySettingsBloc() : super(ProxySettingsState(proxyDetails: [])) {
    on<LoadProxyDetails>(_loadProxyDetails);
    on<SelectProxyProtocol>(_selectProxyProtocol);
  }

  void _loadProxyDetails(
    LoadProxyDetails event,
    Emitter<ProxySettingsState> emit,
  ) async {
    try {
      var proxiesDetails = await getProxyDetails();
      print("DART -> ${proxiesDetails.toString()}");
      emit(state.copyWith(proxyDetails: proxiesDetails));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }

  void _selectProxyProtocol(
    SelectProxyProtocol event,
    Emitter<ProxySettingsState> emit,
  ) {
    emit(state.copyWith(selectedProxy: event.selectedProxyProtocol));
  }
}
