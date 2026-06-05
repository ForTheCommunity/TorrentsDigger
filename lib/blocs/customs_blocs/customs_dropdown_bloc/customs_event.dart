part of 'customs_bloc.dart';

@freezed
class CustomsEvent with _$CustomsEvent {
  const factory CustomsEvent.loadCustoms() = _LoadCustoms;
  const factory CustomsEvent.selectCustomSource({
    required String selectedCustomSource,
    required int selectedCustomSourceIndex,
    required List<String> selectedCustomSourceListings,
  }) = _SelectCustomSource;
  const factory CustomsEvent.selectCustomListing(
    {
      required int selectedListingIndex,
      required String selectedListing
    }
  ) = _SelectCustomListing;
  const factory CustomsEvent.reset() = _Reset;
}
