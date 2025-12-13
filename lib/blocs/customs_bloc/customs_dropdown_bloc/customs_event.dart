part of 'customs_bloc.dart';

@freezed
class CustomsEvent with _$CustomsEvent {
  const factory CustomsEvent.loadCustoms() = _LoadCustoms;
  const factory CustomsEvent.selectCustomListing({
    required String selectedListing,
    required int selectedIndex,
  }) = _SelectCustomListing;
}
