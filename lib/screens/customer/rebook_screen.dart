import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../models/package_model.dart';
import '../../models/delivery_models.dart';
import '../../services/package_service.dart';
import '../../services/matching_service.dart';

class RebookScreen extends StatefulWidget {
  final String packageId;
  const RebookScreen({super.key, required this.packageId});

  @override
  State<RebookScreen> createState() => _RebookScreenState();
}

class _RebookScreenState extends State<RebookScreen> {
  final _packageService = PackageService();
  final _matchingService = MatchingService();

  PackageModel? _original;
  QuoteModel? _quote;

  bool _loading = true;
  bool _quoting = false;
  bool _submitting = false;

  // Editable fields
  late String _packageSize;
  late String _deliverySpeed;
  String _paymentMethod = 'WALLET';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final pkg = await _packageService.getPackageById(widget.packageId);
      if (!mounted) return;
      setState(() {
        _original = pkg;
        _packageSize = pkg.packageSize ?? 'SMALL';
        _deliverySpeed = pkg.deliverySpeed ?? 'STANDARD';
        _loading = false;
      });
      _fetchQuote();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchQuote() async {
    final pkg = _original;
    if (pkg == null) return;
    setState(() { _quoting = true; _quote = null; });
    try {
      final q = await _matchingService.getQuote(
        pickupAddress: pkg.pickupAddress ?? '',
        deliveryAddress: pkg.deliveryAddress ?? '',
        packageSize: _packageSize,
        deliverySpeed: _deliverySpeed,
      );
      if (mounted) setState(() { _quote = q; _quoting = false; });
    } catch (_) {
      if (mounted) setState(() => _quoting = false);
    }
  }

  Future<void> _confirm() async {
    final pkg = _original;
    if (pkg == null) return;
    setState(() => _submitting = true);
    try {
      final newPkg = await _packageService.createPackage(
        pickupAddress: pkg.pickupAddress ?? '',
        deliveryAddress: pkg.deliveryAddress ?? '',
        recipientName: pkg.recipientName ?? '',
        recipientPhone: pkg.recipientPhone ?? '',
        description: pkg.description ?? '',
        category: pkg.category ?? 'OTHERS',
        packageSize: _packageSize,
        deliverySpeed: _deliverySpeed,
        paymentMethod: _paymentMethod,
      );
      if (!mounted) return;
      final id = newPkg.id.isNotEmpty ? newPkg.id : null;
      if (id == null) { context.go('/customer/home'); return; }
      final tn = newPkg.trackingNumber;
      final uri = '/customer/booking-confirm/$id';
      final params = [
        if (tn != null && tn.isNotEmpty) 'trackingNumber=$tn',
        'paymentMethod=$_paymentMethod',
      ].join('&');
      context.go('$uri?$params');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        backgroundColor: AppColors.error,
      ));
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Rebook Delivery',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _original == null
              ? Center(
                  child: Text('Unable to load package',
                      style: GoogleFonts.inter(color: AppColors.textTertiary)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final pkg = _original!;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.25)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.accent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Details are pre-filled from your previous order. You can change the size and speed.',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Route (read-only)
                  _sectionLabel('Route'),
                  const SizedBox(height: 8),
                  _card([
                    _row(Icons.radio_button_checked, AppColors.accent,
                        'Pickup', pkg.pickupAddress ?? '—'),
                    const Padding(
                      padding: EdgeInsets.only(left: 9),
                      child: SizedBox(
                          width: 2,
                          height: 18,
                          child: ColoredBox(color: AppColors.separator)),
                    ),
                    _row(Icons.flag_rounded, AppColors.success,
                        'Delivery', pkg.deliveryAddress ?? '—'),
                  ]),
                  const SizedBox(height: 16),

                  // Recipient (read-only)
                  _sectionLabel('Recipient'),
                  const SizedBox(height: 8),
                  _card([
                    if (pkg.recipientName != null)
                      _row(Icons.person_rounded, AppColors.iosBlue,
                          'Name', pkg.recipientName!),
                    if (pkg.recipientPhone != null) ...[
                      const SizedBox(height: 10),
                      _row(Icons.phone_rounded, AppColors.textSecondary,
                          'Phone', pkg.recipientPhone!),
                    ],
                  ]),
                  const SizedBox(height: 16),

                  // Package size (editable)
                  _sectionLabel('Package Size'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final s in [
                        ('SMALL', 'Small', Icons.mail_outline_rounded),
                        ('MEDIUM', 'Medium', Icons.inventory_2_outlined),
                        ('LARGE', 'Large', Icons.inventory_outlined),
                      ])
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _packageSize = s.$1);
                              _fetchQuote();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: EdgeInsets.only(
                                  right: s.$1 != 'LARGE' ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _packageSize == s.$1
                                    ? AppColors.accentLight
                                    : AppColors.bgPrimary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _packageSize == s.$1
                                      ? AppColors.accent
                                      : AppColors.separator,
                                  width: _packageSize == s.$1 ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(s.$3,
                                      color: _packageSize == s.$1
                                          ? AppColors.accent
                                          : AppColors.textTertiary,
                                      size: 20),
                                  const SizedBox(height: 4),
                                  Text(s.$2,
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Delivery speed (editable)
                  _sectionLabel('Delivery Speed'),
                  const SizedBox(height: 8),
                  for (final item in [
                    ('STANDARD', 'Standard', '2–3 hours', AppColors.iosBlue),
                    ('EXPRESS', 'Express', 'Within the hour', AppColors.success),
                    ('SAME_DAY', 'Same Day', 'By end of day', AppColors.accent),
                  ])
                    GestureDetector(
                      onTap: () {
                        setState(() => _deliverySpeed = item.$1);
                        _fetchQuote();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _deliverySpeed == item.$1
                              ? item.$4.withValues(alpha: 0.08)
                              : AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _deliverySpeed == item.$1
                                ? item.$4
                                : AppColors.separator,
                            width: _deliverySpeed == item.$1 ? 2 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Icon(Icons.access_time_rounded,
                              color: item.$4, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(item.$2,
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary))),
                          Text(item.$3,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textTertiary)),
                          if (_deliverySpeed == item.$1) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.check_circle_rounded,
                                color: item.$4, size: 20),
                          ],
                        ]),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Price
                  _sectionLabel('Price'),
                  const SizedBox(height: 8),
                  _card([
                    if (_quoting)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.accent, strokeWidth: 2)),
                      )
                    else if (_quote != null) ...[
                      if (_quote!.baseFee != null)
                        _priceRow('Base fee',
                            '₦${_quote!.baseFee!.toStringAsFixed(0)}'),
                      if (_quote!.distanceFee != null) ...[
                        const SizedBox(height: 6),
                        _priceRow('Distance fee',
                            '₦${_quote!.distanceFee!.toStringAsFixed(0)}'),
                      ],
                      if (_quote!.sizeFee != null && _quote!.sizeFee! > 0) ...[
                        const SizedBox(height: 6),
                        _priceRow('Size fee',
                            '₦${_quote!.sizeFee!.toStringAsFixed(0)}'),
                      ],
                      if (_quote!.speedFee != null &&
                          _quote!.speedFee! > 0) ...[
                        const SizedBox(height: 6),
                        _priceRow('Speed fee',
                            '₦${_quote!.speedFee!.toStringAsFixed(0)}'),
                      ],
                      const SizedBox(height: 10),
                      const Divider(color: AppColors.separator, thickness: 0.5),
                      const SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            Text(
                                '₦${_quote!.estimatedCost.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent)),
                          ]),
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text('Unable to calculate price',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textTertiary)),
                      ),
                  ]),
                  const SizedBox(height: 16),

                  // Payment method
                  _sectionLabel('Payment Method'),
                  const SizedBox(height: 8),
                  for (final opt in [
                    ('WALLET', Icons.account_balance_wallet_outlined,
                        'TRAKA Wallet', 'Deducted from wallet balance'),
                    ('BANK_TRANSFER', Icons.account_balance_rounded,
                        'Bank Transfer on Delivery',
                        'Pay via transfer when package arrives'),
                    ('CASH', Icons.payments_outlined, 'Cash on Delivery',
                        'Pay the rider in cash at delivery'),
                  ])
                    GestureDetector(
                      onTap: () => setState(() => _paymentMethod = opt.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _paymentMethod == opt.$1
                              ? AppColors.accentLight
                              : AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _paymentMethod == opt.$1
                                ? AppColors.accent
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _paymentMethod == opt.$1
                                  ? AppColors.accent
                                  : AppColors.bgTertiary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(opt.$2,
                                size: 20,
                                color: _paymentMethod == opt.$1
                                    ? Colors.white
                                    : AppColors.textTertiary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(opt.$3,
                                    style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary)),
                                Text(opt.$4,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textTertiary)),
                              ],
                            ),
                          ),
                          if (_paymentMethod == opt.$1)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.accent, size: 20),
                        ]),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
            child: TrakaButton(
              label: 'Confirm & Book',
              loading: _submitting,
              onPressed: (_submitting || _quoting || _quote == null)
                  ? null
                  : _confirm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 3))
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                letterSpacing: 0.5)),
      );

  Widget _row(IconData icon, Color color, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textTertiary)),
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      );

  Widget _priceRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textTertiary)),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      );
}
