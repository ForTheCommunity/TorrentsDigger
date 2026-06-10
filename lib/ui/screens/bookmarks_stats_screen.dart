import 'dart:io';

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
              final isMobile = Platform.isAndroid || Platform.isIOS;
              final isDesktop =
                  Platform.isWindows || Platform.isMacOS || Platform.isLinux;

              double headerFontSize;
              double dataFontSize;
              double totalFontSize;

              if (isMobile) {
                headerFontSize = 16.0;
                dataFontSize = 14.0;
                totalFontSize = 16.0;
              } else if (isDesktop) {
                headerFontSize = 20.0;
                dataFontSize = 18.0;
                totalFontSize = 21.5;
              } else {
                // Fallback (web, unknown platform, etc.)
                headerFontSize = 18.0;
                dataFontSize = 16.0;
                totalFontSize = 20.0;
              }

              return ListView(
                padding: const EdgeInsets.all(15.0),
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // subtract horizontalMargin (12) × 2 sides × 3 columns = 72
                      final availableWidth = constraints.maxWidth - 72;
                      final categoryColWidth = availableWidth * 0.38;
                      final torrentsColWidth = availableWidth * 0.22;
                      final sizeColWidth = availableWidth * 0.40;

                      // helper to build header label
                      Widget headerLabel(String text, double width) => SizedBox(
                        width: width,
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: context
                                .appColors
                                .bookmarksStatsColumnHeaderTextColor,
                            fontSize: headerFontSize,
                          ),
                        ),
                      );

                      // helper to build data cell text
                      Widget dataCell(
                        String text,
                        double width, {
                        bool bold = false,
                        bool ellipsis = false,
                        required Color color,
                      }) => SizedBox(
                        width: width,
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          overflow: ellipsis
                              ? TextOverflow.ellipsis
                              : TextOverflow.visible,
                          style: TextStyle(
                            fontWeight: bold
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: color,
                            fontSize: bold ? totalFontSize : dataFontSize,
                            letterSpacing: 1,
                          ),
                        ),
                      );

                      return DataTable(
                        columnSpacing: 0,
                        horizontalMargin: 12,
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 60,
                        border: TableBorder(
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
                          horizontalInside: BorderSide(
                            color: context.appColors.bookmarksStatsBorderColor,
                            width: 1,
                          ),
                          verticalInside: BorderSide(
                            color: context.appColors.bookmarksStatsBorderColor,
                          ),
                        ),
                        columns: [
                          DataColumn(
                            label: headerLabel("Category", categoryColWidth),
                          ),
                          DataColumn(
                            label: headerLabel("Count", torrentsColWidth),
                          ),
                          DataColumn(label: headerLabel("Size", sizeColWidth)),
                        ],
                        rows: [
                          // category rows
                          ...bookmarksStatsData.categoriesStats.map((
                            categoryStats,
                          ) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  dataCell(
                                    categoryStats.category.name,
                                    ellipsis: true,
                                    categoryColWidth,
                                    color: context
                                        .appColors
                                        .bookmarksStatsCategoryDataTextColor,
                                  ),
                                ),
                                DataCell(
                                  dataCell(
                                    "${categoryStats.categoryTotalCount}",
                                    torrentsColWidth,
                                    color: context
                                        .appColors
                                        .bookmarksStatsCategoryDataTextColor,
                                  ),
                                ),
                                DataCell(
                                  dataCell(
                                    categoryStats.categoryTotalSize,
                                    sizeColWidth,
                                    color: context
                                        .appColors
                                        .bookmarksStatsCategoryDataTextColor,
                                  ),
                                ),
                              ],
                            );
                          }),

                          // total row
                          DataRow(
                            cells: [
                              DataCell(
                                dataCell(
                                  "Total",
                                  categoryColWidth,
                                  bold: true,
                                  color: context
                                      .appColors
                                      .bookmarksStatsTotalTextColor,
                                ),
                              ),
                              DataCell(
                                dataCell(
                                  '${bookmarksStatsData.globalStats.totalTorrentsCount}',
                                  torrentsColWidth,
                                  bold: true,
                                  color: context
                                      .appColors
                                      .bookmarksStatsTotalTextColor,
                                ),
                              ),
                              DataCell(
                                dataCell(
                                  bookmarksStatsData
                                      .globalStats
                                      .totalTorrentsSize,
                                  sizeColWidth,
                                  bold: true,
                                  color: context
                                      .appColors
                                      .bookmarksStatsTotalTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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
