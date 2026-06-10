import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:torrents_digger/src/rust/api/database/bookmark.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

part 'category_event.dart';
part 'category_state.dart';
part 'category_bloc.freezed.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(_Initial()) {
    on<_LoadCategories>(_loadCategories);
    on<_CreateCategory>(_createCategory);
    on<_RenameCategory>(_renameCategory);
    on<_DeleteCategory>(_deleteCategory);
  }

  Future<void> _loadCategories(
    _LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryState.loading());

    try {
      List<InternalBookmarkCategory> categories = await getCategories();
      emit(CategoryState.loaded(categories: categories));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    }
  }

  Future<void> _createCategory(
    _CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await createBookmarkCategory(categoryName: event.newCategoryName);
      createSnackBar(
        message: "Created Category '${event.newCategoryName}'",
        duration: 1,
      );
      final categories = await getCategories();
      emit(CategoryState.loaded(categories: categories));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
    }
  }

  Future<void> _renameCategory(
    _RenameCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await renameBookmarkCategory(
        categoryId: event.categoryId,
        oldCategoryName: event.oldCategoryName,
        newCategoryName: event.newCategoryName,
      );
      createSnackBar(
        message:
            "Category Renamed from '${event.oldCategoryName}' to '${event.newCategoryName}'",
        duration: 2,
      );
      final categories = await getCategories();
      emit(CategoryState.loaded(categories: categories));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
    }
  }

  Future<void> _deleteCategory(
    _DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await deleteBookmarkCategory(categoryId: event.categoryID);
      createSnackBar(message: "Category Deleted...", duration: 1);
      final categories = await getCategories();
      emit(CategoryState.loaded(categories: categories));
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 5);
    }
  }
}
