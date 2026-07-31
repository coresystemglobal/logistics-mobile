import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/rating_service.dart';

final _ratingProvider =
    StateNotifierProvider.autoDispose<_RatingNotifier, _RatingState>(
  (_) => _RatingNotifier(),
);

class _RatingState {
  final int stars;
  final Set<String> tags;
  final String comment;
  final bool loading;
  final bool submitted;

  const _RatingState({
    this.stars = 0,
    this.tags = const {},
    this.comment = '',
    this.loading = false,
    this.submitted = false,
  });

  _RatingState copyWith({int? stars, Set<String>? tags, String? comment, bool? loading, bool? submitted}) =>
      _RatingState(
        stars: stars ?? this.stars,
        tags: tags ?? this.tags,
        comment: comment ?? this.comment,
        loading: loading ?? this.loading,
        submitted: submitted ?? this.submitted,
      );
}

class _RatingNotifier extends StateNotifier<_RatingState> {
  _RatingNotifier() : super(const _RatingState());

  void setStars(int v) => state = state.copyWith(stars: v);
  void toggleTag(String tag) {
    final tags = Set<String>.from(state.tags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    state = state.copyWith(tags: tags);
  }
  void setComment(String v) => state = state.copyWith(comment: v);

  Future<void> submit({required String packageId, required String riderId}) async {
    if (state.stars == 0) return;
    state = state.copyWith(loading: true);
    try {
      await RatingService().createRating(
        packageId: packageId,
        riderId: riderId,
        score: state.stars,
        comment: state.comment.isNotEmpty ? state.comment : null,
      );
      state = state.copyWith(loading: false, submitted: true);
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }
}

class DeliveryCompleteScreen extends ConsumerWidget {
  final String packageId;
  final String riderId;
  final String riderName;
  final double riderRating;
  final String recipientName;
  final String deliveryCode;
  final String deliveryTime;

  const DeliveryCompleteScreen({
    super.key,
    required this.packageId,
    required this.riderId,
    this.riderName = 'Your Rider',
    this.riderRating = 0,
    this.recipientName = '',
    this.deliveryCode = '',
    this.deliveryTime = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_ratingProvider);
    final notifier = ref.read(_ratingProvider.notifier);

    if (state.submitted) {
      return Scaffold(
        backgroundColor: AppColors.bgSecondary,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: AppColors.success, size: 44),
                ),
                const SizedBox(height: 20),
                Text('Thank you!',
                    style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text('Your rating has been submitted.',
                    style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.go('/customer/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Back to Home',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    const praiseChips = ['Fast delivery', 'Very professional', 'Careful with package', 'Friendly'];

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Success hero (40% screen)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 44),
                decoration: const BoxDecoration(
                  color: AppColors.bgSecondary,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
                    ),
                    const SizedBox(height: 16),
                    Text('Delivered!',
                        style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(
                      'Your package was delivered to $recipientName at $deliveryTime',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Code $deliveryCode accepted',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Rating card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppColors.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How was your delivery?',
                          style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 16),

                      // Rider info
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.bgSecondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.accent.withValues(alpha: 0.15), width: 2),
                            ),
                            child: const Icon(Icons.person_rounded, size: 30, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(riderName,
                                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                                  const SizedBox(width: 3),
                                  Text('$riderRating overall',
                                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          final filled = i < state.stars;
                          return GestureDetector(
                            onTap: () => notifier.setStars(i + 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: filled ? AppColors.warning : AppColors.textQuaternary,
                                size: 42,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      // Praise chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: praiseChips.map((chip) {
                            final isSelected = state.tags.contains(chip);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => notifier.toggleTag(chip),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.accentLight : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? AppColors.accent : AppColors.separator,
                                    ),
                                  ),
                                  child: Text(
                                    chip,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: isSelected ? AppColors.accent : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Comment
                      TextField(autocorrect: false, enableSuggestions: false, 
                        maxLines: 3,
                        onChanged: notifier.setComment,
                        style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Add a comment (optional)',
                          hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textQuaternary),
                          filled: true,
                          fillColor: AppColors.bgSecondary,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state.stars == 0 || state.loading
                              ? null
                              : () => notifier.submit(packageId: packageId, riderId: riderId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            disabledBackgroundColor: AppColors.textQuaternary.withValues(alpha: 0.5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: state.loading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : Text('Submit Rating',
                                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => context.go('/customer/home'),
                          child: Text('Skip',
                              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textTertiary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
