import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/database/proxy.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'proxy_settings_bloc.freezed.dart';
part 'proxy_settings_event.dart';
part 'proxy_settings_state.dart';

class ProxySettingsBloc extends Bloc<ProxySettingsEvents, ProxySettingsState> {
  ProxySettingsBloc() : super(ProxySettingsState(proxyDetails: const [])) {
    on<LoadProxyDetailsEvent>(_loadProxyDetails);
    on<SelectProxyProtocolEvent>(_selectProxyProtocol);
    on<SaveProxyEvent>(_saveProxy);
    on<DeleteProxyEvent>(_deleteProxy);
  }

  void _loadProxyDetails(
    LoadProxyDetailsEvent event,
    Emitter<ProxySettingsState> emit,
  ) async {
    try {
      var proxiesDetails = await getSupportedProxyData();
      final savedProxy = await getSavedProxyData();
      emit(
        state.copyWith(proxyDetails: proxiesDetails, savedProxy: savedProxy),
      );
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }

  void _selectProxyProtocol(
    SelectProxyProtocolEvent event,
    Emitter<ProxySettingsState> emit,
  ) {
    emit(state.copyWith(selectedProxy: event.selectedProxyProtocol));
  }

  void _saveProxy(
    SaveProxyEvent event,
    Emitter<ProxySettingsState> emit,
  ) async {
    var proxyUsername = event.proxyUsername;
    if (proxyUsername?.isEmpty ?? false) {
      proxyUsername = null;
    }
    var proxyPassword = event.proxyPassword;
    if (proxyPassword?.isEmpty ?? false) {
      proxyPassword = null;
    }
    try {
      var a = await saveProxy(
        proxyData: InternalProxy(
          id: 1,
          proxyName: event.proxyName,
          proxyType: event.proxyType,
          proxyServerIp: event.proxyServerIp,
          proxyServerPort: event.proxyServerPort,
          proxyUsername: proxyUsername,
          proxyPassword: proxyPassword,
        ),
      );
      createSnackBar(message: "Proxy Saved. $a", duration: 5);

      // Fetch the saved proxy tuple
      final savedProxy = await getSavedProxyData();

      // Emit updated state so UI rebuilds
      emit(state.copyWith(savedProxy: savedProxy));
    } catch (e) {
      createSnackBar(
        message: "Error Saving Proxy.\n${e.toString()}",
        duration: 5,
      );
    }
  }

  Future<void> _deleteProxy(
    DeleteProxyEvent event,
    Emitter<ProxySettingsState> emit,
  ) async {
    try {
      await removeProxy(event.proxyId);
      // updating state
      emit(state.copyWith(savedProxy: null));
      createSnackBar(message: "Proxy Deleted", duration: 3);
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 3);
    }
  }
}
