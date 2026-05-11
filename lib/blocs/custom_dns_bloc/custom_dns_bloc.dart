import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';

part 'custom_dns_event.dart';
part 'custom_dns_state.dart';
part 'custom_dns_bloc.freezed.dart';

class CustomDnsBloc extends Bloc<CustomDnsEvent, CustomDnsState> {
  CustomDnsBloc() : super(_Initial()) {
    on<_LoadCustomDNS>(_loadCustomDNS);
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
          activatedDNSResolver: activeCustomDnsResolverIndex,
        ),
      );
    } catch (e) {}
  }
}
