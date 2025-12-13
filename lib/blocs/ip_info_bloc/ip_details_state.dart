part of 'ip_details_bloc.dart';

@freezed
class IpDetailsState with _$IpDetailsState {
  const factory IpDetailsState.initial() = _Initial;
  const factory IpDetailsState.inProgress() = _InProgress;
  const factory IpDetailsState.success({required String ipAddr}) = _Success;
  const factory IpDetailsState.failed({required String error}) = _Failed;
}
