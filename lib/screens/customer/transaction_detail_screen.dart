import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String? transactionId;
  final String? type;
  final double? amount;
  final String? status;
  final String? method;
  final String? reference;
  final String? narration;
  final String? date;
  final double? balanceAfter;
  final String? packageId;

  const TransactionDetailScreen({
    super.key,
    this.transactionId,
    this.type,
    this.amount,
    this.status,
    this.method,
    this.reference,
    this.narration,
    this.date,
    this.balanceAfter,
    this.packageId,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = (type ?? 'credit') == 'credit';
    final displayAmount = amount ?? 5000;
    final displayStatus = status ?? 'Successful';
    final isSuccess = displayStatus.toLowerCase() == 'successful' || displayStatus.toLowerCase() == 'success';
    final statusColor = isSuccess ? AppColors.success : AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.bgPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 26),
                    color: AppColors.textPrimary,
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Transaction Details',
                      style: GoogleFonts.inter(
                          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.accent),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, size: 22, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Hero section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCredit ? Icons.account_balance_wallet_rounded : Icons.arrow_upward_rounded,
                              color: statusColor,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${isCredit ? '+' : '-'}₦${displayAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              displayStatus,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            date ?? 'May 27, 2024 · 10:22 AM',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),

                    // Details card
                    Container(
                      decoration: AppColors.cardDecoration(),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'Type',
                            value: isCredit ? 'Wallet Funding' : 'Payment',
                            showDivider: true,
                          ),
                          _DetailRow(
                            label: 'Method',
                            value: method ?? 'Paystack · Card',
                            showDivider: true,
                          ),
                          _CopyableRow(
                            label: 'Reference',
                            value: reference ?? 'PAY-20240527-9912',
                          ),
                          _DetailRow(
                            label: 'Transaction ID',
                            value: transactionId ?? 'TXN-884726351',
                            showDivider: true,
                          ),
                          _DetailRow(
                            label: 'Narration',
                            value: narration ?? 'TRAKA Wallet Top-up',
                            showDivider: balanceAfter != null,
                          ),
                          if (balanceAfter != null)
                            _DetailRow(
                              label: 'Balance After',
                              value: '₦${balanceAfter!.toStringAsFixed(2)}',
                              valueColor: AppColors.success,
                              showDivider: false,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Package context
                    if (packageId != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppColors.cardDecoration(),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Package',
                                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary)),
                                  const SizedBox(height: 4),
                                  Text(packageId!,
                                      style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/customer/track/_?id=$packageId'),
                              child: Row(
                                children: [
                                  Text('View Package',
                                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.iosBlue)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.iosBlue),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                        label: Text('Download Receipt',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.iosBlue,
                          side: const BorderSide(color: AppColors.iosBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Report an Issue with this Transaction',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary),
                      ),
                    ),
                    const SizedBox(height: 32),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool showDivider;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
              Text(value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.w400,
                  )),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: AppColors.separator),
      ],
    );
  }
}

class _CopyableRow extends StatelessWidget {
  final String label;
  final String value;

  const _CopyableRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: value));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied: $value'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                Row(
                  children: [
                    Text(value,
                        style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    const Icon(Icons.content_copy_rounded, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.separator),
      ],
    );
  }
}
