import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/opright_button.dart';
import '../../models/package_model.dart';
import '../../services/package_service.dart';

class PendingDeliveryDetailScreen extends StatefulWidget {
  final String packageId;
  const PendingDeliveryDetailScreen({super.key, required this.packageId});

  @override
  State<PendingDeliveryDetailScreen> createState() =>
      _PendingDeliveryDetailScreenState();
}

class _PendingDeliveryDetailScreenState
    extends State<PendingDeliveryDetailScreen> {
  final _packageService = PackageService();
  PackageModel? _package;
  bool _loading = true;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final pkg = await _packageService.getPackageById(widget.packageId);
      if (mounted) setState(() { _package = pkg; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel() async {
    const reasons = [
      ('LONG_PICKUP_TIME', 'Long pickup time'),
      ('FOUND_ALTERNATIVE', 'Found an alternative'),
      ('WRONG_ORDER_DETAILS', 'Wrong order details'),
      ('RIDER_ASKING_DIFFERENT_MONEY', 'Rider asking for different price than app'),
      ('RIDER_UNTIDY_NO_UNIFORM', 'Rider untidy / not in uniform'),
      ('OTHER', 'Other reason'),
    ];

    String? selectedReason;
    final noteCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.separator,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Cancel Delivery',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text('Please tell us why you\'re cancelling.',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textTertiary)),
              const SizedBox(height: 20),
              ...reasons.map((r) => GestureDetector(
                onTap: () => setSheet(() => selectedReason = r.$1),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: selectedReason == r.$1
                        ? AppColors.accentLight
                        : AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedReason == r.$1
                          ? AppColors.accent
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(r.$2,
                          style: GoogleFonts.inter(
                              fontSize: 15, color: AppColors.textPrimary)),
                    ),
                    if (selectedReason == r.$1)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.accent, size: 20),
                  ]),
                ),
              )),
              if (selectedReason == 'OTHER') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                      fontSize: 15, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Please describe the reason (min 10 chars)…',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textQuaternary),
                    filled: true,
                    fillColor: AppColors.bgSecondary,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (selectedReason == null ||
                              (selectedReason == 'OTHER' &&
                                  noteCtrl.text.trim().length < 10))
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          setState(() => _cancelling = true);
                          try {
                            await _packageService.cancelPackage(
                              widget.packageId,
                              selectedReason!,
                              false,
                              cancellationNote: selectedReason == 'OTHER'
                                  ? noteCtrl.text.trim()
                                  : null,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Delivery cancelled'),
                                  backgroundColor: AppColors.success,
                                ));
                              context.go('/customer/history');
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => _cancelling = false);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(e
                                    .toString()
                                    .replaceAll('Exception: ', '')),
                                backgroundColor: AppColors.error,
                              ));
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.error.withValues(alpha: 0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Confirm Cancellation',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    noteCtrl.dispose();
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
        title: Text('Delivery Details',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
          : _package == null
              ? Center(
                  child: Text('Unable to load package',
                      style: GoogleFonts.inter(
                          fontSize: 15, color: AppColors.textTertiary)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final pkg = _package!;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: pkg.isCancelled
                          ? AppColors.error.withValues(alpha: 0.08)
                          : AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: pkg.isCancelled
                              ? AppColors.error.withValues(alpha: 0.3)
                              : AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Icon(
                        pkg.isCancelled
                            ? Icons.cancel_outlined
                            : Icons.hourglass_top_rounded,
                        color: pkg.isCancelled
                            ? AppColors.error
                            : AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pkg.isCancelled ? 'Delivery Cancelled' : 'Awaiting Rider',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: pkg.isCancelled
                                      ? AppColors.error
                                      : AppColors.warning),
                            ),
                            Text(
                              pkg.isCancelled
                                  ? (pkg.cancellationReason ?? 'This delivery was cancelled')
                                      .replaceAll('_', ' ')
                                      .toLowerCase()
                                  : 'No rider has been assigned yet.',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Tracking number
                  if (pkg.trackingNumber != null) ...[
                    _card([
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tracking Number',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textTertiary)),
                          Row(children: [
                            Text(pkg.trackingNumber!,
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 1)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: pkg.trackingNumber!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Copied'),
                                      duration: Duration(seconds: 2)));
                              },
                              child: const Icon(Icons.copy_rounded,
                                  color: AppColors.iosBlue, size: 16),
                            ),
                          ]),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 12),
                  ],

                  // Route
                  _sectionLabel('Route'),
                  const SizedBox(height: 8),
                  _card([
                    _detailRow(Icons.radio_button_checked, AppColors.accent,
                        'Pickup', pkg.pickupAddress),
                    const Padding(
                      padding: EdgeInsets.only(left: 9),
                      child: SizedBox(
                          width: 2, height: 20,
                          child: ColoredBox(color: AppColors.separator)),
                    ),
                    _detailRow(Icons.flag_rounded, AppColors.success,
                        'Delivery', pkg.deliveryAddress),
                  ]),
                  const SizedBox(height: 12),

                  // Recipient
                  _sectionLabel('Recipient'),
                  const SizedBox(height: 8),
                  _card([
                    if (pkg.recipientName != null)
                      _detailRow(Icons.person_rounded, AppColors.iosBlue,
                          'Name', pkg.recipientName!),
                    if (pkg.recipientPhone != null) ...[
                      const SizedBox(height: 10),
                      _detailRow(Icons.phone_rounded, AppColors.textSecondary,
                          'Phone', pkg.recipientPhone!),
                    ],
                  ]),
                  const SizedBox(height: 12),

                  // Package info
                  _sectionLabel('Package'),
                  const SizedBox(height: 8),
                  _card([
                    Row(children: [
                      Expanded(
                          child: _detailRow(
                              Icons.inventory_2_outlined, AppColors.accent,
                              'Size', pkg.packageSize ?? '—')),
                      Expanded(
                          child: _detailRow(
                              Icons.access_time_rounded, AppColors.success,
                              'Speed',
                              (pkg.deliverySpeed ?? 'STANDARD')
                                  .replaceAll('_', ' '))),
                    ]),
                    if (pkg.description != null && pkg.description!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _detailRow(Icons.label_outline_rounded,
                          AppColors.textTertiary, 'Description',
                          pkg.description!),
                    ],
                  ]),
                  const SizedBox(height: 12),

                  // Cost
                  if (pkg.totalAmount != null) ...[
                    _sectionLabel('Cost'),
                    const SizedBox(height: 8),
                    _card([
                      _detailRow(Icons.payments_outlined, AppColors.warning,
                          'Delivery Fee',
                          '₦${pkg.totalAmount!.toStringAsFixed(0)}'),
                    ]),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Action buttons — hidden for cancelled packages
          if (!pkg.isCancelled)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
              child: Column(
                children: [
                  OprightButton(
                    label: 'Search for Rider',
                    icon: const Icon(Icons.search_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () =>
                        context.go('/customer/finding-rider/${widget.packageId}'),
                  ),
                  const SizedBox(height: 10),
                  OprightButton(
                    label: 'Cancel Delivery',
                    variant: OprightBtnVariant.danger,
                    loading: _cancelling,
                    onPressed: _cancelling ? null : _cancel,
                  ),
                ],
              ),
            ),
          if (pkg.isCancelled)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
              child: OprightButton(
                label: 'Rebook Delivery',
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 20),
                onPressed: () =>
                    context.push('/customer/rebook/${widget.packageId}'),
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

  Widget _detailRow(
      IconData icon, Color iconColor, String label, String value) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
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
}
