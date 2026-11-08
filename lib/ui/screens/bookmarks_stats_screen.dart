import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmarks_stats_bloc/bookmarks_stats_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/themes/app_theme.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';

// -----------------------------------------------------------------------------
// COLOR PALETTE & HELPERS
// -----------------------------------------------------------------------------
const List<Color> _palette = [
  Color(0xFF38BDF8), // Sky blue
  Color(0xFF34D399), // Emerald
  Color(0xFFFBBF24), // Amber
  Color(0xFFA78BFA), // Violet
  Color(0xFFF472B6), // Pink
  Color(0xFFFB923C), // Orange
  Color(0xFF2DD4BF), // Teal
  Color(0xFF818CF8), // Indigo
];

Color _getColorForIndex(int index) => _palette[index % _palette.length];

double _parseSizeToBytes(String sizeStr) {
  final clean = sizeStr.trim().toUpperCase();
  final parts = clean.split(RegExp(r'\s+'));
  if (parts.isEmpty) return 0;
  final numVal = double.tryParse(parts[0]) ?? 0;
  if (parts.length < 2) return numVal;
  final unit = parts[1];
  if (unit.contains('TB')) return numVal * 1024 * 1024 * 1024 * 1024;
  if (unit.contains('GB')) return numVal * 1024 * 1024 * 1024;
  if (unit.contains('MB')) return numVal * 1024 * 1024;
  if (unit.contains('KB')) return numVal * 1024;
  return numVal;
}

// -----------------------------------------------------------------------------
// SORTING OPTIONS
// -----------------------------------------------------------------------------
enum StatsSortOption {
  mostTorrents('Torrents', Icons.numbers_rounded),
  largestSize('Storage', Icons.storage_rounded),
  alphabetical('Name', Icons.sort_by_alpha_rounded);

  final String label;
  final IconData icon;

  const StatsSortOption(this.label, this.icon);
}

// -----------------------------------------------------------------------------
// MAIN SCREEN
// -----------------------------------------------------------------------------
class BookmarksStatsScreen extends StatefulWidget {
  const BookmarksStatsScreen({super.key});

  @override
  State<BookmarksStatsScreen> createState() => _BookmarksStatsScreenState();
}

class _BookmarksStatsScreenState extends State<BookmarksStatsScreen> {
  StatsSortOption _currentSortOption = StatsSortOption.mostTorrents;

  @override
  void initState() {
    super.initState();
    context.read<BookmarksStatsBloc>().add(const BookmarksStatsEvent.load());
  }

  List<InternalCategoryStats> _sortCategories(
    List<InternalCategoryStats> list,
    StatsSortOption sortOption,
  ) {
    final copy = List<InternalCategoryStats>.from(list);
    switch (sortOption) {
      case StatsSortOption.mostTorrents:
        copy.sort(
          (a, b) => b.categoryTotalCount.compareTo(a.categoryTotalCount),
        );
        break;
      case StatsSortOption.largestSize:
        copy.sort(
          (a, b) => _parseSizeToBytes(b.categoryTotalSize).compareTo(
            _parseSizeToBytes(a.categoryTotalSize),
          ),
        );
        break;
      case StatsSortOption.alphabetical:
        copy.sort(
          (a, b) => a.category.name.toLowerCase().compareTo(
                b.category.name.toLowerCase(),
              ),
        );
        break;
    }
    return copy;
  }

  List<InternalTagStats> _sortTags(
    List<InternalTagStats> list,
    StatsSortOption sortOption,
  ) {
    final copy = List<InternalTagStats>.from(list);
    switch (sortOption) {
      case StatsSortOption.mostTorrents:
        copy.sort((a, b) => b.tagTotalCount.compareTo(a.tagTotalCount));
        break;
      case StatsSortOption.largestSize:
        copy.sort(
          (a, b) => _parseSizeToBytes(b.tagTotalSize).compareTo(
            _parseSizeToBytes(a.tagTotalSize),
          ),
        );
        break;
      case StatsSortOption.alphabetical:
        copy.sort(
          (a, b) =>
              a.tag.name.toLowerCase().compareTo(b.tag.name.toLowerCase()),
        );
        break;
    }
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks Stats',
          style: TextStyle(
            color: colors.appBarTextColor,
            letterSpacing: 1.2,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: colors.appBarBackButtonIconColor,
            size: 24,
          ),
        ),
        actions: [
          // Sort Menu
          PopupMenuButton<StatsSortOption>(
            tooltip: 'Sort by',
            icon: Icon(
              Icons.sort_rounded,
              color: colors.appBarTextColor,
              size: 22,
            ),
            color: colors.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.5),
              ),
            ),
            initialValue: _currentSortOption,
            onSelected: (option) {
              setState(() {
                _currentSortOption = option;
              });
            },
            itemBuilder: (context) {
              return StatsSortOption.values.map((option) {
                final isSelected = option == _currentSortOption;
                return PopupMenuItem<StatsSortOption>(
                  value: option,
                  child: Row(
                    children: [
                      Icon(
                        option.icon,
                        size: 18,
                        color: isSelected
                            ? colors.bookmarksStatsIconColor
                            : colors.cardSecondaryTextColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Sort by ${option.label}',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                            ? colors.bookmarksStatsColumnHeaderTextColor
                            : colors.cardPrimaryTextColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),

          // Refresh Button
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: colors.appBarTextColor,
              size: 22,
            ),
            tooltip: 'Refresh statistics',
            onPressed: () {
              context.read<BookmarksStatsBloc>().add(
                    const BookmarksStatsEvent.load(),
                  );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<BookmarksStatsBloc, BookmarksStatsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const CircularProgressBarWidget(),
            loaded: (bookmarksStatsData) {
              final globalStats = bookmarksStatsData.globalStats;
              final rawCategories = bookmarksStatsData.categoriesStats;
              final rawTags = bookmarksStatsData.tagsStats;

              if (globalStats.totalTorrentsCount == 0) {
                return _EmptyStatsView(
                  onRefresh: () {
                    context.read<BookmarksStatsBloc>().add(
                          const BookmarksStatsEvent.load(),
                        );
                  },
                );
              }

              // Apply current sorting
              final categoriesStats = _sortCategories(
                rawCategories,
                _currentSortOption,
              );
              final tagsStats = _sortTags(
                rawTags,
                _currentSortOption,
              );

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    children: [
                      // Unified Top KPI Summary
                      _UnifiedKPISummary(
                        globalStats: globalStats,
                        categoriesCount: categoriesStats.length,
                        tagsCount: tagsStats.length,
                      ),

                      const SizedBox(height: 20),

                      // Category Ledger Table
                      if (categoriesStats.isNotEmpty) ...[
                        _SectionTitle(
                          title: 'Category Ledger',
                          count: categoriesStats.length,
                          icon: Icons.table_rows_rounded,
                          accentColor:
                              colors.bookmarksStatsColumnHeaderTextColor,
                        ),
                        const SizedBox(height: 12),
                        _CategoryDataTable(
                          categoriesStats: categoriesStats,
                          globalStats: globalStats,
                        ),
                      ],

                      // Tags Ledger Table
                      if (tagsStats.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _SectionTitle(
                          title: 'Tags Ledger',
                          count: tagsStats.length,
                          icon: Icons.local_offer_rounded,
                          accentColor: colors.bookmarksStatsIconColor,
                        ),
                        const SizedBox(height: 12),
                        _TagDataTable(tagsStats: tagsStats),
                      ],

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// UNIFIED KPI SUMMARY (Clean horizontal metric strip)
// -----------------------------------------------------------------------------
class _UnifiedKPISummary extends StatelessWidget {
  final InternalGlobalStats globalStats;
  final int categoriesCount;
  final int tagsCount;

  const _UnifiedKPISummary({
    required this.globalStats,
    required this.categoriesCount,
    required this.tagsCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 460;

          if (isNarrow) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MetricItem(
                        icon: Icons.bookmark_rounded,
                        iconColor: colors.bookmarksStatsTotalTextColor,
                        value: '${globalStats.totalTorrentsCount}',
                        label: 'Torrents',
                      ),
                    ),
                    _verticalDivider(colors),
                    Expanded(
                      child: _MetricItem(
                        icon: Icons.storage_rounded,
                        iconColor: colors.bookmarksStatsColumnHeaderTextColor,
                        value: globalStats.totalTorrentsSize,
                        label: 'Total Size',
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 20,
                  color:
                      colors.bookmarksStatsBorderColor.withValues(alpha: 0.4),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _MetricItem(
                        icon: Icons.category_rounded,
                        iconColor: _palette[0],
                        value: '$categoriesCount',
                        label: 'Categories',
                      ),
                    ),
                    _verticalDivider(colors),
                    Expanded(
                      child: _MetricItem(
                        icon: Icons.local_offer_rounded,
                        iconColor: _palette[3],
                        value: '$tagsCount',
                        label: 'Tags',
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.bookmark_rounded,
                  iconColor: colors.bookmarksStatsTotalTextColor,
                  value: '${globalStats.totalTorrentsCount}',
                  label: 'Torrents',
                ),
              ),
              _verticalDivider(colors),
              Expanded(
                child: _MetricItem(
                  icon: Icons.storage_rounded,
                  iconColor: colors.bookmarksStatsColumnHeaderTextColor,
                  value: globalStats.totalTorrentsSize,
                  label: 'Storage',
                ),
              ),
              _verticalDivider(colors),
              Expanded(
                child: _MetricItem(
                  icon: Icons.category_rounded,
                  iconColor: _palette[0],
                  value: '$categoriesCount',
                  label: 'Categories',
                ),
              ),
              _verticalDivider(colors),
              Expanded(
                child: _MetricItem(
                  icon: Icons.local_offer_rounded,
                  iconColor: _palette[3],
                  value: '$tagsCount',
                  label: 'Tags',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _verticalDivider(AppTheme colors) {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.4),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MetricItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: colors.cardSecondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: colors.bookmarksStatsCategoryDataTextColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CATEGORY DATA TABLE (Structured Ledger)
// -----------------------------------------------------------------------------
class _CategoryDataTable extends StatelessWidget {
  final List<InternalCategoryStats> categoriesStats;
  final InternalGlobalStats globalStats;

  const _CategoryDataTable({
    required this.categoriesStats,
    required this.globalStats,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final total = globalStats.totalTorrentsCount;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 11,
            ),
            color: colors.bookmarksStatsBorderColor.withValues(
              alpha: 0.25,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'CATEGORY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: colors.cardSecondaryTextColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'COUNT',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: colors.cardSecondaryTextColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SHARE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: colors.cardSecondaryTextColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'STORAGE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: colors.cardSecondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoriesStats.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final cat = categoriesStats[index];
              final color = _getColorForIndex(index);
              final pct = total > 0
                  ? (cat.categoryTotalCount / total * 100).toStringAsFixed(1)
                  : '0.0';

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: index.isEven
                    ? Colors.transparent
                    : colors.bookmarksStatsBorderColor.withValues(
                        alpha: 0.08,
                      ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cat.category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color:
                                    colors.bookmarksStatsCategoryDataTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${cat.categoryTotalCount}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.bookmarksStatsCategoryDataTextColor,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '$pct%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.cardSecondaryTextColor,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        cat.categoryTotalSize,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Table Total Footer
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: colors.bookmarksStatsBorderColor.withValues(
                alpha: 0.2,
              ),
              border: Border(
                top: BorderSide(
                  color:
                      colors.bookmarksStatsBorderColor.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Total (${categoriesStats.length})',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: colors.bookmarksStatsCategoryDataTextColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${globalStats.totalTorrentsCount}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors.bookmarksStatsTotalTextColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '100%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: colors.cardSecondaryTextColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    globalStats.totalTorrentsSize,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors.bookmarksStatsTotalTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAG DATA TABLE (Structured Ledger)
// -----------------------------------------------------------------------------
class _TagDataTable extends StatelessWidget {
  final List<InternalTagStats> tagsStats;

  const _TagDataTable({required this.tagsStats});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 11,
            ),
            color: colors.bookmarksStatsBorderColor.withValues(
              alpha: 0.25,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'TAG',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: colors.cardSecondaryTextColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'COUNT',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: colors.cardSecondaryTextColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'STORAGE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: colors.cardSecondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tagsStats.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: colors.bookmarksStatsBorderColor.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final tag = tagsStats[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                color: index.isEven
                    ? Colors.transparent
                    : colors.bookmarksStatsBorderColor.withValues(
                        alpha: 0.08,
                      ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            size: 14,
                            color: colors.bookmarksStatsIconColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tag.tag.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    colors.bookmarksStatsCategoryDataTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${tag.tagTotalCount}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.bookmarksStatsCategoryDataTextColor,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        tag.tagTotalSize,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.cardSecondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION TITLE
// -----------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color accentColor;

  const _SectionTitle({
    required this.title,
    required this.count,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Icon(icon, size: 18, color: accentColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: colors.bookmarksStatsCategoryDataTextColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// EMPTY STATS VIEW
// -----------------------------------------------------------------------------
class _EmptyStatsView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyStatsView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.bookmarksStatsIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.query_stats_rounded,
                size: 52,
                color: colors.bookmarksStatsIconColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No Bookmarks Yet',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: colors.bookmarksStatsCategoryDataTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark torrents to view category distributions, storage footprints, and tag analytics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: colors.cardSecondaryTextColor.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.bookmarksStatsIconColor,
                side: BorderSide(
                  color:
                      colors.bookmarksStatsBorderColor.withValues(alpha: 0.8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
