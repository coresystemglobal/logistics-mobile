import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../models/package_model.dart';
import '../../services/package_service.dart';

enum _SearchState { searching, riderFound, noRider, scheduled }

class FindingRiderScreen extends StatefulWidget {
  final String packageId;

  const FindingRiderScreen({super.key, required this.packageId});

  @override
  State<FindingRiderScreen> createState() => _FindingRiderScreenState();
}

class _FindingRiderScreenState extends State<FindingRiderScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _dotsCtrl;

  Timer? _pollTimer;
  Timer? _timeoutTimer;
  PackageModel? _package;
  _SearchState _state = _SearchState.searching;
  int _elapsedSeconds = 0;
  static const _timeoutSeconds = 300; // 5 minutes

  final _packageService = PackageService();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _startPolling();
    _startTimeout();
  }

  void _startTimeout() {
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
      if (_elapsedSeconds >= _timeoutSeconds &&
          _state == _SearchState.searching) {
        _pollTimer?.cancel();
        setState(() => _state = _SearchState.noRider);
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _checkStatus());
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final pkg = await _packageService.getPackageById(widget.packageId);
      if (!mounted) return;
      setState(() => _package = pkg);

      if (pkg.riderId != null && pkg.riderId!.isNotEmpty) {
        _pollTimer?.cancel();
        _timeoutTimer?.cancel();
        setState(() => _state = _SearchState.riderFound);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          context.go('/customer/track/${pkg.trackingNumber ?? '_'}?id=${widget.packageId}');
        }
      }
    } catch (_) {}
  }

  Future<void> _searchAgain() async {
    setState(() {
      _state = _SearchState.searching;
      _elapsedSeconds = 0;
    });
    _startPolling();
    _startTimeout();
  }

  Future<void> _showCancelSheet() async {
    const reasons = [
      ('FOUND_ALTERNATIVE', 'Found an alternative'),
      ('WRONG_ORDER_DETAILS', 'Wrong order details'),
      ('LONG_PICKUP_TIME', 'Taking too long'),
      ('OTHER', 'Other reason'),
    ];

    String? selectedReason;
    final noteCtrl = TextEditingController();
    bool cancelling = false;

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
                              fontSize: 15,
                              color: AppColors.textPrimary)),
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
                                  noteCtrl.text.trim().length < 10) ||
                              cancelling)
                      ? null
                      : () async {
                          setSheet(() => cancelling = true);
                          try {
                            await _packageService.cancelPackage(
                              widget.packageId,
                              selectedReason!,
                              false,
                              cancellationNote: selectedReason == 'OTHER'
                                  ? noteCtrl.text.trim()
                                  : null,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) context.go('/customer/home');
                          } catch (e) {
                            setSheet(() => cancelling = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
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
                  child: cancelling
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text('Confirm Cancellation',
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

  Future<void> _schedule() async {
    try {
      await ApiClient.instance.post(
        ApiEndpoints.scheduleBackgroundSearch,
        data: {'package_id': widget.packageId},
      );
    } catch (_) {}
    if (mounted) setState(() => _state = _SearchState.scheduled);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _dotsCtrl.dispose();
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riderFound = _state == _SearchState.riderFound;
    final noRider = _state == _SearchState.noRider;
    final scheduled = _state == _SearchState.scheduled;
    final remaining = (_timeoutSeconds - _elapsedSeconds).clamp(0, _timeoutSeconds);

    // Scheduled state — full screen message, no map needed
    if (scheduled) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.iosBlue.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active_rounded,
                      color: AppColors.iosBlue, size: 52),
                ),
                const SizedBox(height: 32),
                Text('We\'re on it!',
                    style: GoogleFonts.inter(fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Text(
                  'We\'ll alert you when we get a rider for you.\nYou can close this screen and go about your day.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 16,
                      color: AppColors.textTertiary, height: 1.55),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          color: AppColors.iosBlue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _package?.trackingNumber ?? 'Your package',
                          style: GoogleFonts.inter(fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TrakaButton(
                  label: 'Back to Home',
                  onPressed: () => context.go('/customer/home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // ── Map area ──
          Positioned.fill(
            bottom: _bottomSheetHeight(context),
            child: _MapArea(pulseCtrl: _pulseCtrl, riderFound: riderFound),
          ),

          // ── Bottom panel ──
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _BottomPanel(
              package: _package,
              state: _state,
              dotsCtrl: _dotsCtrl,
              remainingSeconds: remaining,
              onCancel: _showCancelSheet,
              onSearchAgain: _searchAgain,
              onSchedule: _schedule,
            ),
          ),

          // ── Back button ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => context.go('/customer/home'),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8, offset: const Offset(0, 2))
                  ],
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textPrimary, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _bottomSheetHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.48;
  }
}

// ── Map placeholder with pulsing rider pins ──────────────────────────────────
class _MapArea extends StatelessWidget {
  final AnimationController pulseCtrl;
  final bool riderFound;

  const _MapArea({required this.pulseCtrl, required this.riderFound});

  // Lagos centre — default when no package location available
  static const _defaultLat = 6.5244;
  static const _defaultLng = 3.3792;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Real OSM tile map
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(_defaultLat, _defaultLng),
            initialZoom: 14,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.traka.mobile',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: [
                // Pickup marker
                Marker(
                  point: const LatLng(_defaultLat, _defaultLng),
                  width: 48,
                  height: 48,
                  child: const Icon(Icons.location_on_rounded,
                      color: AppColors.accent, size: 40),
                ),
              ],
            ),
          ],
        ),

        // Pulsing search radius overlay
        Center(
          child: AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, __) {
              final scale = 0.7 + pulseCtrl.value * 0.6;
              return Opacity(
                opacity: (1 - pulseCtrl.value) * 0.35,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (riderFound
                              ? AppColors.success
                              : AppColors.accent)
                          .withValues(alpha: 0.15),
                      border: Border.all(
                        color: riderFound
                            ? AppColors.success
                            : AppColors.accent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Bottom panel ─────────────────────────────────────────────────────────────
class _BottomPanel extends StatelessWidget {
  final PackageModel? package;
  final _SearchState state;
  final AnimationController dotsCtrl;
  final int remainingSeconds;
  final VoidCallback onCancel;
  final VoidCallback onSearchAgain;
  final VoidCallback onSchedule;

  const _BottomPanel({
    required this.package,
    required this.state,
    required this.dotsCtrl,
    required this.remainingSeconds,
    required this.onCancel,
    required this.onSearchAgain,
    required this.onSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final riderFound = state == _SearchState.riderFound;
    final noRider = state == _SearchState.noRider;
    final searching = state == _SearchState.searching;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Color(0x18000000), blurRadius: 20, offset: Offset(0, -4))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── No rider state ──
          if (noRider) ...[
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_bike_rounded,
                      color: AppColors.warning, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Riders are currently busy',
                          style: GoogleFonts.inter(fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Text('No rider accepted within 5 minutes',
                          style: GoogleFonts.inter(fontSize: 13,
                              color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.separator, thickness: 0.5),
            const SizedBox(height: 20),
            TrakaButton(
              label: 'Search Again',
              onPressed: onSearchAgain,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 10),
            TrakaButton(
              label: 'Search in Background',
              variant: TrakaBtnVariant.secondary,
              onPressed: onSchedule,
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.accent, size: 20),
            ),
            const SizedBox(height: 10),
            TrakaButton(
              label: 'Cancel',
              variant: TrakaBtnVariant.ghost,
              onPressed: onCancel,
            ),
          ] else ...[
            // ── Searching / Rider found status row ──
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: riderFound
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.accent.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    riderFound
                        ? Icons.check_circle_rounded
                        : Icons.delivery_dining_rounded,
                    color: riderFound ? AppColors.success : AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        riderFound ? 'Rider Assigned!' : 'Searching for a rider…',
                        style: GoogleFonts.inter(fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                      Text(
                        riderFound
                            ? 'Heading to your tracking screen'
                            : 'Looking for riders near your pickup',
                        style: GoogleFonts.inter(fontSize: 13,
                            color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                if (searching) _AnimatedDots(ctrl: dotsCtrl),
              ],
            ),

            // Countdown progress bar
            if (searching) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: remainingSeconds / 300,
                  backgroundColor: AppColors.bgTertiary,
                  color: remainingSeconds < 60 ? AppColors.warning : AppColors.accent,
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')} remaining',
                style: GoogleFonts.inter(fontSize: 11,
                    color: remainingSeconds < 60
                        ? AppColors.warning
                        : AppColors.textQuaternary),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(color: AppColors.separator, thickness: 0.5),
            const SizedBox(height: 16),

            // Booking details
            if (package != null) ...[
              _DetailRow(
                icon: Icons.radio_button_checked,
                iconColor: AppColors.accent,
                label: 'Pickup',
                value: package!.pickupAddress,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.flag_rounded,
                iconColor: AppColors.textPrimary,
                label: 'Delivery',
                value: package!.deliveryAddress,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.inventory_2_outlined,
                      iconColor: AppColors.iosBlue,
                      label: 'Size',
                      value: package!.packageSize ?? '—',
                    ),
                  ),
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.access_time_rounded,
                      iconColor: AppColors.success,
                      label: 'Speed',
                      value: (package!.deliverySpeed ?? 'STANDARD')
                          .replaceAll('_', ' '),
                    ),
                  ),
                ],
              ),
              if (package!.totalAmount != null) ...[
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.payments_outlined,
                  iconColor: AppColors.warning,
                  label: 'Total',
                  value: '₦${package!.totalAmount!.toStringAsFixed(0)}',
                ),
              ],
            ] else ...[
              _SkeletonRow(),
              const SizedBox(height: 10),
              _SkeletonRow(),
            ],

            const SizedBox(height: 24),
            if (searching)
              TrakaButton(
                label: 'Cancel Search',
                variant: TrakaBtnVariant.ghost,
                onPressed: onCancel,
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textTertiary)),
              Text(value, style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  final AnimationController ctrl;
  const _AnimatedDots({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final step = (ctrl.value * 3).floor();
        return Row(
          children: List.generate(3, (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == step ? AppColors.accent : AppColors.bgTertiary,
            ),
          )),
        );
      },
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(7),
      ),
    );
  }
}
