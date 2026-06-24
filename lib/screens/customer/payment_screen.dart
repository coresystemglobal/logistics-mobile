import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../models/package_model.dart';
import '../../services/package_service.dart';

class PaymentScreen extends StatefulWidget {
  final String packageId;

  const PaymentScreen({super.key, required this.packageId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _packageService = PackageService();
  PackageModel? _package;
  double? _walletBalance;
  bool _loading = true;
  bool _paying = false;
  String _selectedMethod = 'wallet';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _packageService.getPackageById(widget.packageId),
        ApiClient.instance.get(ApiEndpoints.walletBalance),
      ]);
      if (mounted) {
        setState(() {
          _package = results[0] as PackageModel;
          final balanceData = results[1] as Map<String, dynamic>;
          _walletBalance = num.tryParse(
                  balanceData['balance']?.toString() ?? '')?.toDouble() ??
              0.0;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _amount =>
      _package?.totalAmount ?? _package?.estimatedCost ?? 0;

  bool get _walletSufficient =>
      _walletBalance != null && _walletBalance! >= _amount;

  Future<void> _pay() async {
    if (_selectedMethod == 'wallet' && !_walletSufficient) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Insufficient wallet balance. You need ₦${_amount.toStringAsFixed(0)} but have ₦${_walletBalance?.toStringAsFixed(0) ?? '0'}.'),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'Top Up',
          textColor: Colors.white,
          onPressed: () => context.push('/customer/fund-wallet'),
        ),
      ));
      return;
    }
    setState(() => _paying = true);
    try {
      if (_selectedMethod == 'wallet') {
        await ApiClient.instance.post(
          ApiEndpoints.walletPayForDelivery,
          data: {'package_id': widget.packageId},
        );
        if (mounted) context.go('/customer/finding-rider/${widget.packageId}');
      } else {
        if (mounted) context.go('/customer/finding-rider/${widget.packageId}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _paying = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  Text('Payment', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.accent)))
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text('Amount to Pay', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(
                              _package?.totalAmount != null
                                  ? '₦${_package!.totalAmount!.toStringAsFixed(0)}'
                                  : _package?.estimatedCost != null
                                      ? '₦${_package!.estimatedCost!.toStringAsFixed(0)}'
                                      : '—',
                              style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            if (_package?.trackingNumber != null) ...[
                              const SizedBox(height: 8),
                              Text(_package!.trackingNumber!, style: GoogleFonts.inter(fontSize: 13, color: Colors.white60, letterSpacing: 1.2)),
                            ],
                            if (_selectedMethod == 'wallet' && !_walletSufficient && _walletBalance != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Wallet short by ₦${(_amount - _walletBalance!).toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Payment method
                      Text('Payment Method', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      _MethodTile(
                        id: 'wallet',
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'TRAKA Wallet',
                        subtitle: _walletBalance != null
                            ? 'Balance: ₦${_walletBalance!.toStringAsFixed(0)}'
                            : 'Pay from your wallet balance',
                        selected: _selectedMethod == 'wallet',
                        insufficient: !_walletSufficient,
                        onTap: () => setState(() => _selectedMethod = 'wallet'),
                      ),
                      const SizedBox(height: 10),
                      _MethodTile(
                        id: 'card',
                        icon: Icons.credit_card_rounded,
                        title: 'Debit / Credit Card',
                        subtitle: 'Pay with Paystack or Flutterwave',
                        selected: _selectedMethod == 'card',
                        onTap: () => setState(() => _selectedMethod = 'card'),
                      ),
                      const SizedBox(height: 10),
                      _MethodTile(
                        id: 'transfer',
                        icon: Icons.swap_horiz_rounded,
                        title: 'Bank Transfer',
                        subtitle: 'Generate a virtual account',
                        selected: _selectedMethod == 'transfer',
                        onTap: () => setState(() => _selectedMethod = 'transfer'),
                      ),

                      const SizedBox(height: 24),

                      // Order summary
                      Text('Order Summary', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            if (_package?.pickupAddress != null)
                              _SummaryRow(Icons.radio_button_checked, AppColors.accent, 'Pickup', _package!.pickupAddress),
                            if (_package?.deliveryAddress != null) ...[
                              const SizedBox(height: 10),
                              _SummaryRow(Icons.flag_rounded, AppColors.textPrimary, 'Delivery', _package!.deliveryAddress),
                            ],
                            if (_package?.deliverySpeed != null) ...[
                              const SizedBox(height: 10),
                              _SummaryRow(Icons.access_time_rounded, AppColors.iosBlue, 'Speed', _package!.deliverySpeed!.replaceAll('_', ' ')),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Pay button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: TrakaButton(
                label: _selectedMethod == 'wallet' && !_walletSufficient
                    ? 'Top Up Wallet'
                    : 'Pay Now',
                loading: _paying,
                onPressed: _paying
                    ? null
                    : _selectedMethod == 'wallet' && !_walletSufficient
                        ? () => context.push('/customer/fund-wallet')
                        : _pay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool insufficient;
  final VoidCallback onTap;

  const _MethodTile({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    this.insufficient = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentLight : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? (insufficient ? AppColors.error : AppColors.accent)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? (insufficient ? AppColors.error : AppColors.accent)
                    : AppColors.bgTertiary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: selected ? Colors.white : AppColors.textTertiary,
                  size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: insufficient && selected
                              ? AppColors.error
                              : AppColors.textTertiary)),
                ],
              ),
            ),
            if (selected && insufficient)
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 22)
            else if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SummaryRow(this.icon, this.iconColor, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary)),
              Text(value, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
