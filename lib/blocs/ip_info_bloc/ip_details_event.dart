part of 'ip_details_bloc.dart';

@freezed
class IpDetailsEvent with _$IpDetailsEvent {
  const factory IpDetailsEvent.started() = _Started;
  const factory IpDetailsEvent.extractIpDetails() = _ExtractIpDetails;
}
