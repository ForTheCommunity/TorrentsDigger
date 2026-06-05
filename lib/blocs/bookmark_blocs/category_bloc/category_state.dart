part of 'category_bloc.dart';

@freezed
class CategoryState with _$CategoryState {
  const factory CategoryState.initial() = _Initial;
  const factory CategoryState.loading() = _CategoriesLoading;
  const factory CategoryState.loaded({
    required List<InternalBookmarkCategory> categories,
  }) = _CategoriesLoaded;
 
}
