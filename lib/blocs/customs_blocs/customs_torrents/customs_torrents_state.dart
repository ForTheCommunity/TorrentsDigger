part of 'customs_torrents_bloc.dart';

@freezed
class CustomsTorrentsState with _$CustomsTorrentsState {
  const factory CustomsTorrentsState.initial() = _Initial;
  const factory CustomsTorrentsState.loading() = _Loading;
  const factory CustomsTorrentsState.loaded({
    required List<InternalTorrent> torrents,
  }) = _Loaded;
  const factory CustomsTorrentsState.error({required String errorMessage}) =
      _Error;
}
