import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_service.dart';

final _earningsProvider = FutureProvider.autoDispose<WalletModel>(
  (_) => WalletService().getBalance(),
);

final _earningsTxProvider =
    FutureProvider.autoDispose<List<WalletTransactionModel>>(
  (_) => WalletService().getTransactions(limit: 50),
);

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(_earningsProvider);
    final txAsync = ref.watch(_earningsTxProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bgPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Text('Earnings',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
                onPressed: () {
                  ref.invalidate(_earningsProvider);
                  ref.invalidate(_earningsTxProvider);
                },
              ),
            ],
          ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Balance card
                    walletAsync.when(
                      loading: () => const _Skeleton(height: 160),
                      error: (_, __) => _errorCard('Could not load balance',
                          () => ref.invalidate(_earningsProvider)),
                      data: (wallet) => Container(
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
                            Text('Current Balance',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color:
                                        Colors.white.withValues(alpha: 0.8))),
                            const SizedBox(height: 8),
                            Text('₦${wallet.balance.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 44,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () =>
                                    context.push('/withdrawal'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.accent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                child: Text('Withdraw Funds',
                                    style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats derived from real transactions
                    txAsync.when(
                      loading: () => const Row(children: [
                        Expanded(child: _Skeleton(height: 80)),
                        SizedBox(width: 12),
                        Expanded(child: _Skeleton(height: 80)),
                      ]),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (txs) {
                        final deliveries = txs
                            .where((t) => t.type == 'TRIP_EARNING')
                            .length;
                        final totalEarned = txs
                            .where((t) => t.amount > 0)
                            .fold(0.0, (s, t) => s + t.amount);
                        return Row(children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Deliveries\nCompleted',
                              value: '$deliveries',
                              icon: Icons.local_shipping_rounded,
                              iconColor: AppColors.iosBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Total\nEarned',
                              value:
                                  '₦${totalEarned.toStringAsFixed(0)}',
                              icon: Icons.trending_up_rounded,
                              iconColor: AppColors.success,
                            ),
                          ),
                        ]);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Earnings history
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Earnings History',
                            style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        TextButton(
                          onPressed: () =>
                              context.push('/transactions'),
                          child: Text('See all',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.iosBlue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    txAsync.when(
                      loading: () => Column(
                        children: List.generate(
                            3, (_) => const _Skeleton(height: 70, bottom: 10)),
                      ),
                      error: (e, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Could not load history',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textTertiary)),
                        ),
                      ),
                      data: (txs) {
                        if (txs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(children: [
                                const Icon(Icons.receipt_long_outlined,
                                    size: 48,
                                    color: AppColors.textQuaternary),
                                const SizedBox(height: 12),
                                Text('No earnings yet',
                                    style: GoogleFonts.inter(
                                        fontSize: 15,
                                        color: AppColors.textTertiary)),
                              ]),
                            ),
                          );
                        }
                        return Column(
                          children: txs
                              .map((t) => _EarningRow(tx: t))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _errorCard(String msg, VoidCallback onRetry) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
              child: Text(msg,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textTertiary))),
          TextButton(
              onPressed: onRetry,
              child: Text('Retry',
                  style: GoogleFonts.inter(color: AppColors.accent))),
        ]),
      );
}

class _Skeleton extends StatelessWidget {
  final double height;
  final double bottom;
  const _Skeleton({required this.height, this.bottom = 0});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        margin: EdgeInsets.only(bottom: bottom),
        decoration: BoxDecoration(
            color: AppColors.bgTertiary,
            borderRadius: BorderRadius.circular(14)),
      );
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
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  height: 1.4)),
        ],
      ),
    );
  }
}

class _EarningRow extends StatelessWidget {
  final WalletTransactionModel tx;
  const _EarningRow({required this.tx});

  String get _label {
    switch (tx.type) {
      case 'TRIP_EARNING': return 'Trip Earning';
      case 'COMMISSION_DEBIT': return 'Platform Commission';
      case 'WITHDRAWAL': return 'Withdrawal';
      case 'DEPOSIT': return 'Deposit';
      case 'DEBT_REPAYMENT': return 'Debt Repayment';
      default: return tx.type.replaceAll('_', ' ');
    }
  }

  bool get _isDebit => tx.amount < 0;

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final time =
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
    if (diff.inDays == 0) return 'Today, $time';
    if (diff.inDays == 1) return 'Yesterday, $time';
    return '${dt.day}/${dt.month}/${dt.year}, $time';
  }

  @override
  Widget build(BuildContext context) {
    final time = tx.createdAt != null ? _formatDate(tx.createdAt!) : '';

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
              offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (_isDebit ? AppColors.error : AppColors.success)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isDebit
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: _isDebit ? AppColors.error : AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description ?? _label,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(time,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textQuaternary)),
              ],
            ),
          ),
          Text(
            '${_isDebit ? '–' : '+'}₦${tx.amount.abs().toStringAsFixed(0)}',
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _isDebit ? AppColors.textPrimary : AppColors.success),
          ),
        ],
      ),
    );
  }
}
