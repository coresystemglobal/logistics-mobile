import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_service.dart';

final _earningsProvider = FutureProvider.autoDispose<WalletModel>(
  (ref) async => WalletService().getBalance(),
);

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(_earningsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: earningsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (wallet) {
            final balance = wallet.balance;
            return CustomScrollView(
              slivers: [
                // Sticky header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _EarningsHeader(),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Balance card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, Color(0xFFFF9500)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Balance',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₦${balance.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 44,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.accent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Withdraw Funds',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stats row
                        const Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Deliveries\nCompleted',
                                value: '47',
                                icon: Icons.local_shipping_rounded,
                                iconColor: AppColors.iosBlue,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Total\nEarned',
                                value: '₦94,800',
                                icon: Icons.trending_up_rounded,
                                iconColor: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Transactions section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Earnings History',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'See all',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.iosBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Sample earnings items
                        ...const [
                          _EarningData(
                            title: 'Delivery Completed',
                            subtitle: '#TRK-8829 · Lekki → VI',
                            amount: '+₦4,200',
                            time: 'Today, 2:34 PM',
                          ),
                          _EarningData(
                            title: 'Delivery Completed',
                            subtitle: '#TRK-7712 · Ikeja → Yaba',
                            amount: '+₦2,800',
                            time: 'Today, 10:15 AM',
                          ),
                          _EarningData(
                            title: 'Delivery Completed',
                            subtitle: '#TRK-6621 · Ajah → Lekki',
                            amount: '+₦3,500',
                            time: 'Yesterday, 5:00 PM',
                          ),
                          _EarningData(
                            title: 'Withdrawal',
                            subtitle: 'Bank Transfer · GTB ****4821',
                            amount: '–₦20,000',
                            time: 'Jun 1, 11:00 AM',
                            isDebit: true,
                          ),
                        ].map((e) => _EarningRow(data: e)),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EarningsHeader extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.bgPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        'Earnings',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_EarningsHeader old) => false;
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningData {
  final String title;
  final String subtitle;
  final String amount;
  final String time;
  final bool isDebit;

  const _EarningData({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
    this.isDebit = false,
  });
}

class _EarningRow extends StatelessWidget {
  final _EarningData data;
  const _EarningRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.isDebit
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.isDebit
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: data.isDebit ? AppColors.error : AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  data.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  data.time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textQuaternary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.amount,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: data.isDebit
                  ? AppColors.textPrimary
                  : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
