import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../services/package_service.dart';
import '../../models/package_model.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String trackingNumber;
  final String? packageId;
  const TrackingScreen({super.key, required this.trackingNumber, this.packageId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  PackageModel? _package;
  bool _isLoading = true;
  String? _error;
  final _packageService = PackageService();
  Timer? _pollTimer;
  bool _pickupDialogShown = false;

  @override
  void initState() {
    super.initState();
    _loadPackage();
    // Poll every 8 seconds while screen is open to catch rider arrival
    _pollTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _pollStatus(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _pollStatus() async {
    if (!mounted) return;
    try {
      final PackageModel pkg;
      if (widget.packageId != null && widget.packageId!.isNotEmpty) {
        pkg = await _packageService.getPackageById(widget.packageId!);
      } else {
        pkg = await _packageService.trackPackage(widget.trackingNumber);
      }
      if (!mounted) return;
      final previousStatus = _package?.status;
      setState(() => _package = pkg);

      // Show pickup code when rider arrives (status becomes OUT_FOR_DELIVERY)
      // and we haven't shown it yet this session
      if (!_pickupDialogShown &&
          pkg.status == 'OUT_FOR_DELIVERY' &&
          previousStatus != 'OUT_FOR_DELIVERY' &&
          pkg.pickupPin != null) {
        _pickupDialogShown = true;
        _showPickupCodeDialog(pkg.pickupPin!);
      }
    } catch (_) {}
  }

  Future<void> _loadPackage() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final PackageModel pkg;
      if (widget.packageId != null && widget.packageId!.isNotEmpty) {
        pkg = await _packageService.getPackageById(widget.packageId!);
      } else {
        pkg = await _packageService.trackPackage(widget.trackingNumber);
      }
      if (mounted) setState(() { _package = pkg; _isLoading = false; });

      // If screen is opened when rider is already at pickup, show code immediately
      if (mounted &&
          pkg.status == 'OUT_FOR_DELIVERY' &&
          !_pickupDialogShown &&
          pkg.pickupPin != null) {
        _pickupDialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _showPickupCodeDialog(pkg.pickupPin!),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      }
    }
  }

  void _showPickupCodeDialog(String pin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.bgPrimary,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delivery_dining_rounded,
                    color: AppColors.accent, size: 32),
              ),
              const SizedBox(height: 16),
              Text('Your rider has arrived!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('Share this pickup code with the rider to hand over your package.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                      height: 1.5)),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: pin));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Pickup code copied'),
                        duration: Duration(seconds: 2)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pin,
                        style: GoogleFonts.inter(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 10),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.copy_rounded,
                          color: Colors.white70, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Dismiss',
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_TrackingStep> _buildSteps(PackageModel pkg) {
    final isTransit = pkg.status == 'IN_TRANSIT';
    final isDelivered = pkg.deliveredAt != null;
    return [
      _TrackingStep(
        title: 'Order Placed',
        subtitle: 'Package registered in system',
        isComplete: true,
        time: pkg.createdAt,
      ),
      _TrackingStep(
        title: 'Picked Up',
        subtitle: 'Package collected by rider',
        isComplete: pkg.pickedUpAt != null,
        time: pkg.pickedUpAt,
      ),
      _TrackingStep(
        title: 'In Transit',
        subtitle: 'Package is on its way to you',
        isComplete: isTransit || isDelivered,
      ),
      _TrackingStep(
        title: 'Delivered',
        subtitle: 'Package delivered successfully',
        isComplete: isDelivered,
        time: pkg.deliveredAt,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.accent, strokeWidth: 2))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 16),
                        Text(_error!,
                            style: GoogleFonts.inter(
                                color: AppColors.textTertiary)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadPackage,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _buildContent(_package!),
      ),
    );
  }

  Widget _buildContent(PackageModel pkg) {
    final steps = _buildSteps(pkg);
    return RefreshIndicator(
      onRefresh: _loadPackage,
      color: AppColors.accent,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bgPrimary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Package Detail',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.textPrimary),
                onPressed: _loadPackage,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pkg.trackingNumber ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            StatusBadge(
                                status: pkg.status.toLowerCase()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Route
                        _RouteRow(
                          icon: Icons.radio_button_checked,
                          color: AppColors.accent,
                          label: 'From',
                          address: pkg.pickupAddress,
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 4, 0, 4),
                          height: 24,
                          width: 1.5,
                          color: AppColors.separator,
                        ),
                        _RouteRow(
                          icon: Icons.flag_rounded,
                          color: AppColors.textPrimary,
                          label: 'To',
                          address: pkg.deliveryAddress,
                        ),
                        if (pkg.estimatedCost != null) ...[
                          const SizedBox(height: 16),
                          const Divider(
                              color: AppColors.separator, thickness: 0.5),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivery fee',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.textTertiary)),
                              Text(
                                '₦${pkg.estimatedCost!.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rider card
                  if (pkg.rider != null) ...[
                    _RiderCard(rider: pkg.rider!),
                    const SizedBox(height: 20),
                  ],

                  // Timeline
                  Text(
                    'Tracking Timeline',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
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
                      children: steps.asMap().entries.map((entry) {
                        final isLast = entry.key == steps.length - 1;
                        return _TimelineItem(
                            step: entry.value, isLast: isLast);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions
                  if (pkg.isActive) ...[
                    if (pkg.status == 'OUT_FOR_DELIVERY' && pkg.pickupPin != null) ...[
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showPickupCodeDialog(pkg.pickupPin!),
                          icon: const Icon(Icons.pin_outlined, size: 20),
                          label: const Text('Show Pickup Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (pkg.riderId != null)
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/customer/chat/${pkg.id}'),
                          icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 20),
                          label: const Text('Message Rider'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.iosBlue,
                            side: const BorderSide(
                                color: AppColors.iosBlue),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 120),
                  ] else
                    const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String address;

  const _RouteRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textTertiary)),
              Text(address,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _RiderCard extends StatelessWidget {
  final Map<String, dynamic> rider;
  const _RiderCard({required this.rider});

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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.textTertiary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rider['name']?.toString() ?? 'Your Rider',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (rider['vehicle_type'] != null)
                  Text(
                    rider['vehicle_type'].toString(),
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textTertiary),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.warning, size: 16),
              const SizedBox(width: 4),
              Text(
                rider['rating']?.toString() ?? '5.0',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final _TrackingStep step;
  final bool isLast;

  const _TimelineItem({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: step.isComplete
                    ? AppColors.accent
                    : AppColors.bgSecondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.isComplete
                      ? AppColors.accent
                      : AppColors.separator,
                  width: 2,
                ),
              ),
              child: step.isComplete
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                margin: const EdgeInsets.symmetric(vertical: 3),
                color: step.isComplete
                    ? AppColors.accent.withValues(alpha: 0.3)
                    : AppColors.separator,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: step.isComplete
                        ? AppColors.textPrimary
                        : AppColors.textQuaternary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
                if (step.time != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    _formatTime(step.time!),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime t) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '${months[t.month - 1]} ${t.day}, $h:$m';
  }
}

class _TrackingStep {
  final String title;
  final String subtitle;
  final bool isComplete;
  final DateTime? time;

  const _TrackingStep({
    required this.title,
    required this.subtitle,
    required this.isComplete,
    this.time,
  });
}
