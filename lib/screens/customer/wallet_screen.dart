import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/opright_button.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_service.dart';

final _walletProvider = FutureProvider.autoDispose<WalletModel>(
  (_) => WalletService().getBalance(),
);

final _transactionsProvider =
    FutureProvider.autoDispose<List<WalletTransactionModel>>(
  (_) => WalletService().getTransactions(limit: 10),
);

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(_walletProvider);
    final txAsync = ref.watch(_transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.bgPrimary,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              title: Text('My Wallet',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.accent),
                  onPressed: () {
                    ref.invalidate(_walletProvider);
                    ref.invalidate(_transactionsProvider);
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
                      loading: () => _BalanceSkeleton(),
                      error: (_, __) => _BalanceError(
                          onRetry: () => ref.invalidate(_walletProvider)),
                      data: (wallet) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, Color(0xFFFF9500)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Available Balance',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                )),
                            const SizedBox(height: 8),
                            Text(
                              '₦${wallet.balance.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (wallet.isNegative) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Credit limit: ₦${wallet.creditLimit.abs().toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color:
                                        Colors.white.withValues(alpha: 0.7)),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Row(children: [
                              Expanded(
                                child: OprightButton(
                                  label: 'Add Money',
                                  height: 44,
                                  onPressed: () =>
                                      context.push('/customer/fund-wallet'),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Spend stats derived from transactions
                    txAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (txs) {
                        final totalSpent = txs
                            .where((t) => t.amount < 0)
                            .fold(0.0, (s, t) => s + t.amount.abs());
                        final totalFunded = txs
                            .where((t) => t.amount > 0)
                            .fold(0.0, (s, t) => s + t.amount);
                        return Row(children: [
                          Expanded(
                            child: _WalletStat(
                              label: 'Total Spent',
                              value: '₦${totalSpent.toStringAsFixed(0)}',
                              icon: Icons.trending_down_rounded,
                              iconColor: AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _WalletStat(
                              label: 'Total Funded',
                              value: '₦${totalFunded.toStringAsFixed(0)}',
                              icon: Icons.trending_up_rounded,
                              iconColor: AppColors.success,
                            ),
                          ),
                        ]);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Transactions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Transactions',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            )),
                        GestureDetector(
                          onTap: () =>
                              context.push('/customer/transactions'),
                          child: Text('See all',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.iosBlue,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    txAsync.when(
                      loading: () => Column(
                        children: List.generate(
                            3, (_) => _TransactionSkeleton()),
                      ),
                      error: (e, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Could not load transactions',
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
                              child: Column(
                                children: [
                                  const Icon(
                                      Icons.receipt_long_outlined,
                                      size: 48,
                                      color: AppColors.textQuaternary),
                                  const SizedBox(height: 12),
                                  Text('No transactions yet',
                                      style: GoogleFonts.inter(
                                          fontSize: 15,
                                          color: AppColors.textTertiary)),
                                ],
                              ),
                            ),
                          );
                        }
                        return Column(
                          children:
                              txs.map((t) => _TransactionRow(tx: t)).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(20),
        ),
      );
}

class _BalanceError extends StatelessWidget {
  final VoidCallback onRetry;
  const _BalanceError({required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
              child: Text('Could not load balance',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textTertiary))),
          TextButton(
              onPressed: onRetry,
              child: Text('Retry',
                  style: GoogleFonts.inter(color: AppColors.accent))),
        ]),
      );
}

class _TransactionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 66,
        decoration: BoxDecoration(
          color: AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
      );
}

class _WalletStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _WalletStat({
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
              color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final WalletTransactionModel tx;
  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.amount > 0;
    final label = _label(tx.type);
    final time = tx.createdAt != null ? _formatDate(tx.createdAt!) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description ?? label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(time,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '–'}₦${tx.amount.abs().toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isCredit ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _label(String type) {
    switch (type) {
      case 'DEPOSIT': return 'Wallet Top-up';
      case 'DELIVERY_PAYMENT': return 'Delivery Fee';
      case 'COMMISSION_DEBIT': return 'Commission';
      case 'TRIP_EARNING': return 'Trip Earning';
      case 'WITHDRAWAL': return 'Withdrawal';
      default: return type.replaceAll('_', ' ');
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today, ${_time(dt)}';
    if (diff.inDays == 1) return 'Yesterday, ${_time(dt)}';
    return '${dt.day}/${dt.month}/${dt.year}, ${_time(dt)}';
  }

  String _time(DateTime dt) =>
      '${dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
}
