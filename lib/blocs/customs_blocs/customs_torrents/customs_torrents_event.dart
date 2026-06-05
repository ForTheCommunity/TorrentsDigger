part of 'customs_torrents_bloc.dart';

@freezed
sealed class CustomsTorrentsEvent with _$CustomsTorrentsEvent {
  const factory CustomsTorrentsEvent.searchCustomTorrents({
    required int selectedSourceIndex,
    required int selectedListingIndex
  }) = _SearchTorrents;
  const factory CustomsTorrentsEvent.reset() = _Reset;
}
