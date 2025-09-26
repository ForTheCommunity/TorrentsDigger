import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/ui/widgets/dropdown_widget.dart';

class DropdownsUi extends StatelessWidget {
  const DropdownsUi({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SourceBloc, SourceState>(
      builder: (context, state) {
        if (state.sources.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownWidget(
                    items: state.sources.keys.toList(),
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
                ),
                const SizedBox(width: 16),

                // Category Dropdown
                if (state.selectedDetails != null) ...[
                  if (state.selectedDetails!.queryOptions.categories)
                    Expanded(
                      child: DropdownWidget(
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
                            context.read<SourceBloc>().add(
                              SelectCategory(value),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                // Filter Dropdown
                if (state.selectedDetails != null) ...[
                  if (state.selectedDetails!.queryOptions.filters)
                    Expanded(
                      child: DropdownWidget(
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
                    ),
                ],
                const SizedBox(width: 16),

                // Sorting Dropdown
                if (state.selectedDetails != null) ...[
                  if (state.selectedDetails!.queryOptions.sortings)
                    Expanded(
                      child: Text(
                        "     Sorting Feature will \n     come  in Next Release.",
                      ),
                    ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}
