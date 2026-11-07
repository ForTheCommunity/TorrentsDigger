import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/bookmark_blocs/bookmarks_stats_bloc/bookmarks_stats_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/src/rust/api/internals.dart';
import 'package:torrents_digger/ui/widgets/circular_progress_bar_widget.dart';

const List<Color> _palette = [
  Color(0xFF38BDF8), // sky blue
  Color(0xFF34D399), // emerald green
  Color(0xFFFBBF24), // amber
  Color(0xFFA78BFA), // violet
  Color(0xFFF472B6), // pink
  Color(0xFFFB923C), // orange
  Color(0xFF2DD4BF), // teal
  Color(0xFF818CF8), // indigo
];

class BookmarksStatsScreen extends StatefulWidget {
  const BookmarksStatsScreen({super.key});

  @override
  State<BookmarksStatsScreen> createState() => _BookmarksStatsScreenState();
}

class _BookmarksStatsScreenState extends State<BookmarksStatsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookmarksStatsBloc>().add(const BookmarksStatsEvent.load());
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
            letterSpacing: 1.5,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: colors.appBarBackButtonIconColor,
            size: 26,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: colors.appBarTextColor,
              size: 24,
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
              final categoriesStats = bookmarksStatsData.categoriesStats;
              final tagsStats = bookmarksStatsData.tagsStats;

              if (globalStats.totalTorrentsCount == 0) {
                return _EmptyStatsView(
                  onRefresh: () {
                    context.read<BookmarksStatsBloc>().add(
                          const BookmarksStatsEvent.load(),
                        );
                  },
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 18.0,
                    ),
                    children: [
                      // Two Big Hero Bento Tiles
                      _HeroBentoTiles(
                        globalStats: globalStats,
                        categoriesCount: categoriesStats.length,
                        tagsCount: tagsStats.length,
                      ),

                      const SizedBox(height: 28),

                      // Category Bento Tiles
                      if (categoriesStats.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'Categories',
                          count: categoriesStats.length,
                          icon: Icons.category_rounded,
                          accentColor:
                              colors.bookmarksStatsColumnHeaderTextColor,
                        ),
                        const SizedBox(height: 14),
                        _CategoryBentoGrid(
                          categoriesStats: categoriesStats,
                          totalTorrentsCount: globalStats.totalTorrentsCount,
                        ),
                      ],

                      // Tag Bento Tiles (if tags exist)
                      if (tagsStats.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _SectionHeader(
                          title: 'Tags',
                          count: tagsStats.length,
                          icon: Icons.local_offer_rounded,
                          accentColor: colors.bookmarksStatsIconColor,
                        ),
                        const SizedBox(height: 14),
                        _TagBentoGrid(tagsStats: tagsStats),
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
// HERO BENTO TILES
// -----------------------------------------------------------------------------
class _HeroBentoTiles extends StatelessWidget {
  final InternalGlobalStats globalStats;
  final int categoriesCount;
  final int tagsCount;

  const _HeroBentoTiles({
    required this.globalStats,
    required this.categoriesCount,
    required this.tagsCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 540;
        final double cardWidth = isWide
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Left Hero: Total Bookmarks
            SizedBox(
              width: cardWidth,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.bookmarksStatsBorderColor.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.bookmarksStatsTotalTextColor
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.bookmark_rounded,
                            size: 24,
                            color: colors.bookmarksStatsTotalTextColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.bookmarksStatsTotalTextColor
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$categoriesCount categories',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colors.bookmarksStatsTotalTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${globalStats.totalTorrentsCount}',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: colors.bookmarksStatsCategoryDataTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Bookmarked Torrents',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.cardSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Hero: Total Storage Size
            SizedBox(
              width: cardWidth,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.bookmarksStatsBorderColor.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.bookmarksStatsColumnHeaderTextColor
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.storage_rounded,
                            size: 24,
                            color: colors.bookmarksStatsColumnHeaderTextColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.bookmarksStatsColumnHeaderTextColor
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Cumulative Size',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  colors.bookmarksStatsColumnHeaderTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      globalStats.totalTorrentsSize,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: colors.bookmarksStatsCategoryDataTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Storage Footprint',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.cardSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// CATEGORIES BENTO GRID
// -----------------------------------------------------------------------------
class _CategoryBentoGrid extends StatelessWidget {
  final List<InternalCategoryStats> categoriesStats;
  final int totalTorrentsCount;

  const _CategoryBentoGrid({
    required this.categoriesStats,
    required this.totalTorrentsCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final double cardWidth = isWide
            ? (constraints.maxWidth - (12 * 2)) / 3
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categoriesStats.asMap().entries.map((entry) {
            final idx = entry.key;
            final cat = entry.value;
            final color = _palette[idx % _palette.length];
            final double fraction = totalTorrentsCount > 0
                ? cat.categoryTotalCount / totalTorrentsCount
                : 0.0;

            return SizedBox(
              width: cardWidth,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.bookmarksStatsBorderColor.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.folder_rounded,
                            size: 18,
                            color: color,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(fraction * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      cat.category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colors.bookmarksStatsCategoryDataTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${cat.categoryTotalCount} torrents',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.cardSecondaryTextColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          cat.categoryTotalSize,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// TAGS BENTO GRID
// -----------------------------------------------------------------------------
class _TagBentoGrid extends StatelessWidget {
  final List<InternalTagStats> tagsStats;

  const _TagBentoGrid({required this.tagsStats});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final double cardWidth = isWide
            ? (constraints.maxWidth - (12 * 2)) / 3
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: tagsStats.map((tag) {
            return SizedBox(
              width: cardWidth,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.bookmarksStatsBorderColor.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.bookmarksStatsIconColor.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.label_rounded,
                        size: 16,
                        color: colors.bookmarksStatsIconColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tag.tag.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: colors.bookmarksStatsCategoryDataTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${tag.tagTotalCount} • ${tag.tagTotalSize}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.cardSecondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION HEADER
// -----------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color accentColor;

  const _SectionHeader({
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
        Icon(icon, size: 20, color: accentColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: colors.bookmarksStatsCategoryDataTextColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
                size: 56,
                color: colors.bookmarksStatsIconColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Bookmarks Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.bookmarksStatsCategoryDataTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save torrents to your bookmarks to view category and tag statistics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.cardSecondaryTextColor.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.bookmarksStatsIconColor,
                side: BorderSide(
                  color: colors.bookmarksStatsBorderColor,
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
