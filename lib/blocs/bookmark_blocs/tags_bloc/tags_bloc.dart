import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/database/bookmark.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'tags_event.dart';
part 'tags_state.dart';
part 'tags_bloc.freezed.dart';

class TagsBloc extends Bloc<TagsEvent, TagsState> {
  static const int _allTagssId = 65535;

  TagsBloc() : super(_Initial()) {
    on<_LoadTags>(_loadTags);
    on<_CreateTag>(_createTag);
    on<_RenameTag>(_renameTag);
    on<_DeleteTag>(_deleteTag);
    on<_UpdateTags>(_updateTags);
  }

  Future<void> _loadTags(_LoadTags event, Emitter<TagsState> emit) async {
    emit(TagsState.loading());
    try {
      List<InternalBookmarkTag> bookmarkTags = await getBookmarksTags();
      bookmarkTags.insert(0, InternalBookmarkTag(id: _allTagssId, name: "All"));
      emit(TagsState.loaded(bookmarkTags: bookmarkTags));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }

  Future<void> _createTag(_CreateTag event, Emitter<TagsState> emit) async {
    try {
      await createBookmarksTag(tagName: event.newTagName);
      createSnackBar(message: "Created Tag '${event.newTagName}'", duration: 1);
      final List<InternalBookmarkTag> bookmarkTags = await getBookmarksTags();
      bookmarkTags.insert(0, InternalBookmarkTag(id: _allTagssId, name: "All"));
      emit(TagsState.loaded(bookmarkTags: bookmarkTags));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }

  Future<void> _renameTag(_RenameTag event, Emitter<TagsState> emit) async {
    try {
      await renameBookmarksTag(
        tagId: event.tagId,
        oldTagName: event.oldTagName,
        newTagName: event.newTagName,
      );
      createSnackBar(
        message:
            "Tag Renamed from '${event.oldTagName}' to '${event.newTagName}'",
        duration: 2,
      );
      final List<InternalBookmarkTag> bookmarkTags = await getBookmarksTags();
      bookmarkTags.insert(0, InternalBookmarkTag(id: _allTagssId, name: "All"));
      emit(TagsState.loaded(bookmarkTags: bookmarkTags));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }

  Future<void> _deleteTag(_DeleteTag event, Emitter<TagsState> emit) async {
    try {
      await deleteBookmarksTag(tagId: event.tagID);
      createSnackBar(message: "Tag Deleted...", duration: 1);
      final List<InternalBookmarkTag> bookmarkTags = await getBookmarksTags();
      bookmarkTags.insert(0, InternalBookmarkTag(id: _allTagssId, name: "All"));
      emit(TagsState.loaded(bookmarkTags: bookmarkTags));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }

  Future<void> _updateTags(_UpdateTags event, Emitter<TagsState> emit) async {
    try {
      await updateTorrentTags(
        infoHash: event.infoHash,
        tagIds: event.selectedTagIds,
      );
      createSnackBar(message: "Tag Updated...", duration: 1);
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }
}
