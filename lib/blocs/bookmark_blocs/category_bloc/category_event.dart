part of 'category_bloc.dart';

@freezed
class CategoryEvent with _$CategoryEvent {
  const factory CategoryEvent.started() = _Started;
  const factory CategoryEvent.load() = _LoadCategories;
  const factory CategoryEvent.create({required String newCategoryName}) =
      _CreateCategory;
  const factory CategoryEvent.rename({
    required int categoryId,
    required String oldCategoryName,
    required String newCategoryName,
  }) = _RenameCategory;
  const factory CategoryEvent.delete({required int categoryID}) =
      _DeleteCategory;
}
