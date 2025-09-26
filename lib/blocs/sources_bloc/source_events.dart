part of 'source_bloc.dart';

@immutable
sealed class SourceWidgetEvents {}

class LoadSources extends SourceWidgetEvents {}

class SelectSource extends SourceWidgetEvents {
  final String selectedSource;
  SelectSource({required this.selectedSource});
}

class SelectCategory extends SourceWidgetEvents {
  final String category;
  SelectCategory(this.category);
}

class SelectFilter extends SourceWidgetEvents {
  final String filter;
  SelectFilter(this.filter);
}

class SelectSorting extends SourceWidgetEvents {
  final String sorting;
  SelectSorting({required this.sorting});
}
