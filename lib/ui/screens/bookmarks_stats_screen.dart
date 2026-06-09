import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmarks_stats_bloc/bookmarks_stats_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';

class BookmarksStatsScreen extends StatefulWidget {
  const BookmarksStatsScreen({super.key});

  @override
  State<BookmarksStatsScreen> createState() => _BookmarksStatsScreenState();
}

class _BookmarksStatsScreenState extends State<BookmarksStatsScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatching the load event immediately when the screen initializes
    context.read<BookmarksStatsBloc>().add(const BookmarksStatsEvent.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks Stats',
          style: TextStyle(
            color: context.appColors.appBarTextColor,
            letterSpacing: 2,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
        ),
      ),
      body: BlocBuilder<BookmarksStatsBloc, BookmarksStatsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const CircularProgressBarWidget(),

            loaded: (bookmarksStatsData) {
              final screenWidth = MediaQuery.of(context).size.width;
              final categoryColWidth = screenWidth * 0.35;
              final torrentsColWidth = screenWidth * 0.22;
              final sizeColWidth = screenWidth * 0.28;

              return ListView(
                padding: const EdgeInsets.all(15.0),
                children: [
                  Center(
                    child: DataTable(
                      columnSpacing: 0,
                      dataRowMinHeight: 48,
                      dataRowMaxHeight: 60,

                      border: TableBorder(
                        // Outside border of the entire table
                        top: BorderSide(
                          color: context.appColors.bookmarksStatsBorderColor,
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: context.appColors.bookmarksStatsBorderColor,
                          width: 1,
                        ),
                        left: BorderSide(
                          color: context.appColors.bookmarksStatsBorderColor,
                          width: 1,
                        ),
                        right: BorderSide(
                          color: context.appColors.bookmarksStatsBorderColor,
                          width: 1,
                        ),
                        // Horizontal cell divider lines inside the table
                        horizontalInside: BorderSide(
                          color: context.appColors.bookmarksStatsBorderColor,
                          width: 1.0,
                        ),
                        verticalInside: BorderSide(
                          color: context.appColors.bookmarksStatsBorderColor,
                        ),
                      ),

                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: categoryColWidth,
                            child: Center(
                              child: Text(
                                "Category",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: context
                                      .appColors
                                      .bookmarksStatsColumnHeaderTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: torrentsColWidth,
                            child: Center(
                              child: Text(
                                "Torrents",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: context
                                      .appColors
                                      .bookmarksStatsColumnHeaderTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: sizeColWidth,
                            child: Center(
                              child: Text(
                                "Size",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: context
                                      .appColors
                                      .bookmarksStatsColumnHeaderTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: [
                        ...bookmarksStatsData.categoriesStats.map((
                          categoryStats,
                        ) {
                          return DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: categoryColWidth,
                                  child: Center(
                                    child: Text(
                                      categoryStats.category.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1,
                                        color: context
                                            .appColors
                                            .bookmarksStatsCategoryDataTextColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: torrentsColWidth,
                                  child: Center(
                                    child: Text(
                                      "${categoryStats.categoryTotalCount}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: context
                                            .appColors
                                            .bookmarksStatsCategoryDataTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: sizeColWidth,
                                  child: Center(
                                    child: Text(
                                      categoryStats.categoryTotalSize,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: context
                                            .appColors
                                            .bookmarksStatsCategoryDataTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        // Total row
                        DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: categoryColWidth,
                                child: Center(
                                  child: Text(
                                    "Total",
                                    style: TextStyle(
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.bold,
                                      color: context
                                          .appColors
                                          .bookmarksStatsTotalTextColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: torrentsColWidth,
                                child: Center(
                                  child: Text(
                                    '${bookmarksStatsData.globalStats.totalTorrentsCount}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: context
                                          .appColors
                                          .bookmarksStatsTotalTextColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: sizeColWidth,
                                child: Center(
                                  child: Text(
                                    bookmarksStatsData
                                        .globalStats
                                        .totalTorrentsSize,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: context
                                          .appColors
                                          .bookmarksStatsTotalTextColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
