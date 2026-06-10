import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/wallet_service.dart';

final _fundWalletProvider =
    StateNotifierProvider.autoDispose<_FundNotifier, _FundState>(
  (_) => _FundNotifier(),
);

class _FundState {
  final double amount;
  final String provider;
  final bool loading;
  final String? error;

  const _FundState({
    this.amount = 5000,
    this.provider = 'monnify',
    this.loading = false,
    this.error,
  });

  _FundState copyWith({double? amount, String? provider, bool? loading, String? error}) =>
      _FundState(
        amount: amount ?? this.amount,
        provider: provider ?? this.provider,
        loading: loading ?? this.loading,
        error: error ?? this.error,
      );
}

class _FundNotifier extends StateNotifier<_FundState> {
  _FundNotifier() : super(const _FundState());

  void setAmount(double v) => state = state.copyWith(amount: v);
  void setProvider(String v) => state = state.copyWith(provider: v);

  Future<void> proceed(BuildContext context) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await WalletService().initializeFunding(
        amount: state.amount,
        provider: state.provider,
      );
      state = state.copyWith(loading: false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Redirecting to payment gateway...')),
        );
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

class FundWalletScreen extends ConsumerStatefulWidget {
  const FundWalletScreen({super.key});

  @override
  ConsumerState<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends ConsumerState<FundWalletScreen> {
  final _amountCtrl = TextEditingController(text: '5000');

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_fundWalletProvider);
    final notifier = ref.read(_fundWalletProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                    color: AppColors.textPrimary,
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Fund Wallet',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded, size: 22, color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Amount input
                    Text('Enter Amount',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textTertiary)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0x4DFF6B00), width: 2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('₦',
                              style: GoogleFonts.inter(
                                  fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(width: 4),
                          IntrinsicWidth(
                            child: TextField(
                              controller: _amountCtrl,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: '0',
                              ),
                              onChanged: (v) => notifier.setAmount(double.tryParse(v) ?? 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick amount chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [1000, 2500, 5000, 10000, 20000].map((amt) {
                          final isSelected = state.amount == amt.toDouble();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                _amountCtrl.text = amt.toString();
                                notifier.setAmount(amt.toDouble());
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.accentLight : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppColors.accent : AppColors.separator,
                                  ),
                                ),
                                child: Text(
                                  '₦${_formatAmount(amt)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? AppColors.accent : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Payment methods
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Payment Method',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        _PaymentMethodCard(
                          id: 'monnify',
                          title: 'Bank Transfer',
                          subtitle: 'Instant · No fees',
                          icon: Icons.account_balance_rounded,
                          selected: state.provider == 'monnify',
                          onTap: () => notifier.setProvider('monnify'),
                        ),
                        const SizedBox(height: 10),
                        _PaymentMethodCard(
                          id: 'paystack',
                          title: 'Card / USSD / Bank',
                          subtitle: 'Instant · No fees',
                          icon: Icons.credit_card_rounded,
                          selected: state.provider == 'paystack',
                          onTap: () => notifier.setProvider('paystack'),
                        ),
                        const SizedBox(height: 10),
                        _PaymentMethodCard(
                          id: 'flutterwave',
                          title: 'Card / Mobile Money',
                          subtitle: 'Instant · Processing fee may apply',
                          icon: Icons.payment_rounded,
                          selected: state.provider == 'flutterwave',
                          onTap: () => notifier.setProvider('flutterwave'),
                        ),
                      ],
                    ),

                    if (state.error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(state.error!,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.error)),
                      ),
                    ],
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary.withOpacity(0.95),
          border: Border(top: BorderSide(color: AppColors.separator.withOpacity(0.4))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You pay ₦${_formatAmount(state.amount.toInt())} · No fees',
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: state.loading ? null : () => notifier.proceed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: state.loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text('Proceed to Pay ₦${_formatAmount(state.amount.toInt())}',
                        style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, size: 14, color: AppColors.textQuaternary),
                const SizedBox(width: 4),
                Text('Secured by 256-bit encryption · CBN licensed',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textQuaternary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(int amt) {
    if (amt >= 1000) {
      final s = amt.toString();
      final buf = StringBuffer();
      var count = 0;
      for (var i = s.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) buf.write(',');
        buf.write(s[i]);
        count++;
      }
      return buf.toString().split('').reversed.join();
    }
    return amt.toString();
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentLight : AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.separator,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.separator.withOpacity(0.4)),
              ),
              child: Icon(icon, color: selected ? AppColors.accent : AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                ],
              ),
            ),
            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.separator,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
