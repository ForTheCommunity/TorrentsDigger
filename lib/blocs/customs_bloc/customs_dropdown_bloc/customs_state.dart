part of 'customs_bloc.dart';

@freezed
class CustomsState with _$CustomsState {
  const factory CustomsState.initial() = _Initial;
  const factory CustomsState.loading() = _Loading;
  const factory CustomsState.loaded({
    required List<InternalCustomSourceDetails> customListingSourceDetails,
    String? selectedCustomSource,
    int? selectedCustomSourceIndex,
    List<String>? selectedCustomSourceListings,
    String? selectedCustomSourceListing,
    int? selectedCustomListingIndex,
  }) = _Loaded;
  const factory CustomsState.error({required String errorMessage}) = _Error;
}
