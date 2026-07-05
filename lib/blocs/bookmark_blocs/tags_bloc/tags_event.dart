part of 'tags_bloc.dart';

@freezed
class TagsEvent with _$TagsEvent {
  const factory TagsEvent.started() = _Started;
  const factory TagsEvent.load() = _LoadTags;
  const factory TagsEvent.create({required String newTagName}) = _CreateTag;
  const factory TagsEvent.rename({
    required int tagId,
    required String oldTagName,
    required String newTagName,
  }) = _RenameTag;
  const factory TagsEvent.delete({required int tagID}) = _DeleteTag;
  const factory TagsEvent.updateTags({
    required String infoHash,
    required List<int> selectedTagIds,
  }) = _UpdateTags;
}
