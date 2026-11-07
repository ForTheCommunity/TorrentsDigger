import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/configs/nsfw_helper.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';
import 'package:torrents_digger/ui/widgets/dropdown_widget.dart';

class DropdownsUi extends StatelessWidget {
  const DropdownsUi({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SourceBloc, SourceState>(
      builder: (context, state) {
        if (state.sources.isEmpty) {
          return const Center(child: CircularProgressBarWidget());
        }

        final visibleSources = state.sources.where((source) {
          if (state.hideNsfw && NsfwHelper.isNsfwSource(source.sourceName)) {
            return false;
          }
          if (state.disabledSources.contains(source.sourceName)) {
            return false;
          }
          return true;
        }).map((s) => s.sourceName).toList();

        final selectedSource = (state.selectedSource != null &&
                visibleSources.contains(state.selectedSource))
            ? state.selectedSource
            : null;

        return LayoutBuilder(
          builder: (context, constraints) {
            const double horizontalSpacing = 16.0;
            final double halfWidth =
                (constraints.maxWidth - horizontalSpacing) / 2;
            final List<Widget> dropdownWidgets = [];

            // Source dropdown
            dropdownWidgets.add(
              DropdownWidget(
                items: visibleSources,
                selectedValue: selectedSource,
                hintText: "Select Source",
                onChanged: (value) {
                  if (value != null) {
                    context.read<SourceBloc>().add(
                      SelectSource(selectedSource: value),
                    );
                  }
                },
              ),
            );

            // adding other dropdowns if a source is selected and visible
            if (state.selectedDetails != null && selectedSource != null) {
              if (state.selectedDetails!.queryOptions.categories) {
                final visibleCategories =
                    state.selectedDetails!.categories.where((cat) {
                  if (state.hideNsfw && NsfwHelper.isNsfwCategory(cat)) {
                    return false;
                  }
                  return true;
                }).toList();

                dropdownWidgets.add(
                  DropdownWidget(
                    items: visibleCategories,
                    selectedValue: state.selectedCategory != null &&
                            visibleCategories.contains(state.selectedCategory)
                        ? state.selectedCategory
                        : null,
                    hintText: "Category",
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SourceBloc>().add(SelectCategory(value));
                      }
                    },
                  ),
                );
              }
              if (state.selectedDetails!.queryOptions.filters) {
                dropdownWidgets.add(
                  DropdownWidget(
                    items: state.selectedDetails!.sourceFilters,
                    selectedValue: state.selectedFilter != null &&
                            state.selectedDetails!.sourceFilters.contains(
                              state.selectedFilter,
                            )
                        ? state.selectedFilter
                        : null,
                    hintText: "Filter",
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SourceBloc>().add(SelectFilter(value));
                      }
                    },
                  ),
                );
              }
              if (state.selectedDetails!.queryOptions.sortings) {
                dropdownWidgets.add(
                  DropdownWidget(
                    items: state.selectedDetails!.sourceSortings,
                    selectedValue: state.selectedSorting != null &&
                            state.selectedDetails!.sourceSortings.contains(
                              state.selectedSorting,
                            )
                        ? state.selectedSorting
                        : null,
                    hintText: "Sorting",
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SourceBloc>().add(SelectSorting(value));
                      }
                    },
                  ),
                );
              }
              if (state.selectedDetails!.queryOptions.sortingOrders) {
                dropdownWidgets.add(
                  DropdownWidget(
                    items: state.selectedDetails!.sourceSortingOrders,
                    selectedValue: state.selectedSortingOrder != null &&
                            state.selectedDetails!.sourceSortingOrders.contains(
                              state.selectedSortingOrder,
                            )
                        ? state.selectedSortingOrder
                        : null,
                    hintText: "Sorting Order",
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SourceBloc>().add(
                          SelectSortingOrder(value),
                        );
                      }
                    },
                  ),
                );
              }
            }

            return Wrap(
              spacing: horizontalSpacing,
              runSpacing: 15,
              children: List.generate(dropdownWidgets.length, (index) {
                final bool isLast = index == dropdownWidgets.length - 1;
                final bool isOdd = dropdownWidgets.length % 2 != 0;
                final double width = isLast && isOdd
                    ? constraints.maxWidth
                    : halfWidth;
                return SizedBox(width: width, child: dropdownWidgets[index]);
              }),
            );
          },
        );
      },
    );
  }
}
