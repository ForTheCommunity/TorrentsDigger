import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
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

        return LayoutBuilder(
          builder: (context, constraints) {
            const double horizontalSpacing = 16.0;
            final double halfWidth =
                (constraints.maxWidth - horizontalSpacing) / 2;
            final List<Widget> dropdownWidgets = [];

            // Source dropdown
            dropdownWidgets.add(
              DropdownWidget(
                items: state.sources
                    .map((source) => source.sourceName)
                    .toList(),
                selectedValue: state.selectedSource,
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

            // adding other dropdowns if a source is selected
            if (state.selectedDetails != null) {
              if (state.selectedDetails!.queryOptions.categories) {
                dropdownWidgets.add(
                  DropdownWidget(
                    items: state.selectedDetails!.categories,
                    selectedValue:
                        state.selectedCategory != null &&
                            state.selectedDetails!.categories.contains(
                              state.selectedCategory,
                            )
                        ? state.selectedCategory
                        : null,
                    hintText: "Select Category",
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
                    selectedValue:
                        state.selectedFilter != null &&
                            state.selectedDetails!.sourceFilters.contains(
                              state.selectedFilter,
                            )
                        ? state.selectedFilter
                        : null,
                    hintText: "Select Filter",
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
                    selectedValue:
                        state.selectedSorting != null &&
                            state.selectedDetails!.sourceSortings.contains(
                              state.selectedSorting,
                            )
                        ? state.selectedSorting
                        : null,
                    hintText: "Select Sorting",
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
                    selectedValue:
                        state.selectedSortingOrder != null &&
                            state.selectedDetails!.sourceSortingOrders.contains(
                              state.selectedSortingOrder,
                            )
                        ? state.selectedSortingOrder
                        : null,
                    hintText: "Select Sorting Order",
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
