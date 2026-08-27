import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String? trackingNumber;
  final String? packageId;
  final String paymentMethod;

  const BookingConfirmationScreen({
    super.key,
    this.trackingNumber,
    this.packageId,
    this.paymentMethod = 'WALLET',
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;
  Timer? _redirectTimer;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);

    _startRedirect();
  }

  void _startRedirect() {
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        _navigate();
      }
    });
  }

  void _navigate() {
    if (!mounted || widget.packageId == null) return;
    // On-delivery methods skip payment screen — go straight to finding rider
    if (widget.paymentMethod == 'CASH' || widget.paymentMethod == 'BANK_TRANSFER') {
      context.go('/customer/finding-rider/${widget.packageId}');
    } else {
      context.go('/customer/payment/${widget.packageId}');
    }
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCash = widget.paymentMethod == 'CASH';
    final isBankTransfer = widget.paymentMethod == 'BANK_TRANSFER';
    final isOnDelivery = isCash || isBankTransfer;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Success icon
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Booking Confirmed!',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isOnDelivery
                    ? 'Your delivery has been booked.\nPayment will be collected on delivery.'
                    : 'Your delivery has been booked.\nProceeding to payment…',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textTertiary,
                  height: 1.5,
                ),
              ),

              if (widget.trackingNumber != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tracking Number',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.trackingNumber!,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: widget.trackingNumber!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Icon(Icons.copy_rounded,
                                color: AppColors.iosBlue, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Payment method badge
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isOnDelivery
                      ? AppColors.warning.withValues(alpha: 0.10)
                      : AppColors.accentLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnDelivery
                          ? (isBankTransfer ? Icons.account_balance_rounded : Icons.payments_outlined)
                          : Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: isOnDelivery ? AppColors.warning : AppColors.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isBankTransfer
                          ? 'Bank Transfer on Delivery'
                          : isCash
                              ? 'Cash on Delivery'
                              : 'Opright Wallet',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isOnDelivery ? AppColors.warning : AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Countdown indicator
              Text(
                isOnDelivery
                    ? 'Finding riders in $_countdown…'
                    : 'Redirecting to payment in $_countdown…',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textQuaternary),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (3 - _countdown) / 3,
                backgroundColor: AppColors.bgTertiary,
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(100),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
