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
  SelectSorting(this.sorting);
}

class SelectSortingOrder extends SourceWidgetEvents {
  final String sortingOder;
  SelectSortingOrder(this.sortingOder);
}

class ToggleRememberSelections extends SourceWidgetEvents {
  final bool isEnabled;
  ToggleRememberSelections(this.isEnabled);
}

class ToggleHideNsfw extends SourceWidgetEvents {
  final bool isEnabled;
  ToggleHideNsfw(this.isEnabled);
}

class ToggleSource extends SourceWidgetEvents {
  final String sourceName;
  final bool isEnabled;
  ToggleSource({required this.sourceName, required this.isEnabled});
}

class EnableAllSources extends SourceWidgetEvents {}

class EnableDefaultSources extends SourceWidgetEvents {}

class DisableAllSources extends SourceWidgetEvents {
  final List<String> allSources;
  DisableAllSources(this.allSources);
}
