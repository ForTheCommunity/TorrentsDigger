part of 'customs_bloc.dart';

@freezed
class CustomsState with _$CustomsState {
  const factory CustomsState.initial() = _Initial;
  const factory CustomsState.loading() = _Loading;
  const factory CustomsState.loaded({
    required List<String> customsDetails,
    String? selectedCustomListing,
    int? selectedCustomListingIndex,
    @Default(null) List<InternalTorrent>? torrentsList,
  }) = _Loaded;
  const factory CustomsState.error({required String errorMessage}) = _Error;
}
