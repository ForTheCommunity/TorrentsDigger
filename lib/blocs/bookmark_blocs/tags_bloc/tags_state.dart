part of 'tags_bloc.dart';

@freezed
class TagsState with _$TagsState {
  const factory TagsState.initial() = _Initial;
  const factory TagsState.loading() = _TagsLoading;
  const factory TagsState.loaded({
    required List<InternalBookmarkTag> bookmarkTags,
  }) = _TagsLoaded;
}
