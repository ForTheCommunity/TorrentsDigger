part of 'custom_dns_bloc.dart';

@freezed
class CustomDnsEvent with _$CustomDnsEvent {
  const factory CustomDnsEvent.started() = _Started;
  const factory CustomDnsEvent.loadCustomDNS() = _LoadCustomDNS;
  const factory CustomDnsEvent.setCustomDNS({
    required int selectedCustomDNS,
  }) = _SetCustomDNS;
}
