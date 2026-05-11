part of 'custom_dns_bloc.dart';

@freezed
class CustomDnsState with _$CustomDnsState {
  const factory CustomDnsState.initial() = _Initial;
  const factory CustomDnsState.loading() = _Loading;
  const factory CustomDnsState.loaded({
    required List<InternalCustomDNS> customDNSList,
    required BigInt activatedDNSResolver,
  }) = _Loaded;
}
