import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/rating_model.dart';
import '../../services/rating_service.dart';

final _riderStatsProvider =
    FutureProvider.autoDispose.family<RiderRatingStats, String>(
  (ref, riderId) => RatingService().getRiderStats(riderId),
);

final _riderRatingsProvider =
    FutureProvider.autoDispose.family<List<RatingModel>, String>(
  (ref, riderId) => RatingService().getRiderRatings(riderId),
);

class RatingsScreen extends ConsumerWidget {
  final String riderId;
  final String? riderName;

  const RatingsScreen({super.key, required this.riderId, this.riderName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_riderStatsProvider(riderId));
    final ratingsAsync = ref.watch(_riderRatingsProvider(riderId));

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.bgPrimary,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: AppColors.textPrimary,
                onPressed: () => context.pop(),
              ),
              title: Text(
                riderName != null ? '$riderName · Reviews' : 'Ratings & Reviews',
                style: GoogleFonts.inter(
                    fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),

            // Stats section
            SliverToBoxAdapter(
              child: statsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Could not load stats: $err',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                ),
                data: (stats) => _StatsCard(stats: stats),
              ),
            ),

            // Reviews header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Reviews',
                  style: GoogleFonts.inter(
                      fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
            ),

            // Reviews list
            ratingsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Text('Could not load reviews: $err',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                ),
              ),
              data: (ratings) {
                if (ratings.isEmpty) {
                  return SliverFillRemaining(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.bgSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star_outline_rounded, size: 36, color: AppColors.textQuaternary),
                        ),
                        const SizedBox(height: 14),
                        Text('No reviews yet',
                            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textTertiary)),
                      ],
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ReviewCard(rating: ratings[index]),
                      childCount: ratings.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final RiderRatingStats stats;
  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: AppColors.cardDecoration(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Big average
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    stats.averageRating.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  _StarRow(score: stats.averageRating.round(), size: 18),
                  const SizedBox(height: 4),
                  Text('${stats.totalRatings} ratings',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary)),
                ],
              ),
              const SizedBox(width: 24),
              // Distribution bars
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final count = stats.distribution[star] ?? 0;
                    final fraction = stats.totalRatings > 0 ? count / stats.totalRatings : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text('$star',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary)),
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded, color: AppColors.warning, size: 12),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: fraction,
                                backgroundColor: AppColors.bgSecondary,
                                color: AppColors.warning,
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 24,
                            child: Text('$count',
                                textAlign: TextAlign.right,
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textQuaternary)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.separator, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatPill(label: 'Excellent', count: stats.distribution[5] ?? 0, color: AppColors.success),
              _StatPill(label: 'Good', count: (stats.distribution[4] ?? 0) + (stats.distribution[3] ?? 0), color: AppColors.iosBlue),
              _StatPill(label: 'Poor', count: (stats.distribution[2] ?? 0) + (stats.distribution[1] ?? 0), color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final RatingModel rating;
  const _ReviewCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    final initials = rating.raterId.isNotEmpty ? rating.raterId[0].toUpperCase() : 'U';
    final formattedDate = rating.createdAt != null
        ? _formatDate(rating.createdAt!)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.accentLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(initials,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (formattedDate.isNotEmpty)
                      Text(formattedDate,
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textQuaternary)),
                  ],
                ),
              ),
              _StarRow(score: rating.score, size: 16),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(rating.comment!,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Package: ${rating.packageId}',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _StarRow extends StatelessWidget {
  final int score;
  final double size;

  const _StarRow({required this.score, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < score ? Icons.star_rounded : Icons.star_outline_rounded,
        color: i < score ? AppColors.warning : AppColors.textQuaternary,
        size: size,
      )),
    );
  }
}
