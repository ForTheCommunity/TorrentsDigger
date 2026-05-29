import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/database/get_settings_kv.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'custom_dns_event.dart';
part 'custom_dns_state.dart';
part 'custom_dns_bloc.freezed.dart';

class CustomDnsBloc extends Bloc<CustomDnsEvent, CustomDnsState> {
  CustomDnsBloc() : super(_Initial()) {
    on<_LoadCustomDNS>(_loadCustomDNS);
    on<_SetCustomDNS>(_setCustomDNS);
  }

  Future<void> _loadCustomDNS(
    _LoadCustomDNS event,
    Emitter<CustomDnsState> emit,
  ) async {
    emit(const CustomDnsState.loading());

    try {
      List<InternalCustomDNS> customDNSLists = await getCustomDnsLists();
      String activeCustomDnsResolver = await getActiveCustomDnsResolver() ?? "";

      BigInt activeCustomDnsResolverIndex = BigInt.parse(
        activeCustomDnsResolver,
      );

      emit(
        CustomDnsState.loaded(
          customDNSList: customDNSLists,
          activatedDNSResolver: activeCustomDnsResolverIndex.toInt(),
        ),
      );
    } catch (e) {
      createSnackBar(
        message: "Custom DNS Error : ${e.toString()}",
        duration: 10,
      );
    }
  }

  Future<void> _setCustomDNS(
    _SetCustomDNS event,
    Emitter<CustomDnsState> emit,
  ) async {
    try {
      int selectedCDNS = event.selectedCustomDNS;
      await setActiveCustomDnsResolver(index: selectedCDNS.toInt());

      // updating state
      // getting current state to retrieve existing tracker list
      if (state is _Loaded) {
        var currentState = state as _Loaded;
        emit(
          CustomDnsState.loaded(
            customDNSList: currentState.customDNSList,
            activatedDNSResolver: selectedCDNS,
          ),
        );
      } else {
        createSnackBar(
          message: "STATE ERROR : Unable to get current state..",
          duration: 5,
        );
      }

      createSnackBar(message: "Updated Custom DNS.", duration: 1);
    } catch (e) {
      createSnackBar(
        message: "Custom DNS Error : ${e.toString()}",
        duration: 10,
      );
    }
  }
}
