import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/real_time_service.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String packageId;
  const LiveTrackingScreen({super.key, required this.packageId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  bool _sheetExpanded = false;
  late final AnimationController _pulseCtrl;

  // Simulated live data — in production these come from RealTimeService events
  // ignore: unused_field
  Map<String, dynamic> _riderPosition = {'lat': 6.45, 'lng': 3.45};
  String _status = 'In Transit';
  String _eta = '22 min';
  String _distance = '3.2 km';
  final String _riderName = 'Samuel Okon';
  final String _riderRating = '4.9';
  final String _vehicle = 'White Toyota Hilux • ABC-123-XY';
  final String _pickup = 'Plot 12, Victoria Island Annex';
  final String _dropoff = '15B Admiralty Way, Lekki Phase 1';
  final String _price = '₦2,800';

  StreamSubscription? _locationSub;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _subscribeToLocationUpdates();
  }

  void _subscribeToLocationUpdates() {
    final rt = RealTimeService.instance;
    rt.joinPackage(widget.packageId);
    rt.on('rider_location', (data) {
      if (mounted && data != null) {
        setState(() => _riderPosition = data as Map<String, dynamic>);
      }
    });
    rt.on('eta_update', (data) {
      if (mounted && data != null) {
        final d = data as Map<String, dynamic>;
        setState(() {
          _eta = d['eta'] ?? _eta;
          _distance = d['distance'] ?? _distance;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _locationSub?.cancel();
    RealTimeService.instance.leavePackage(widget.packageId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map placeholder
          Positioned.fill(
            child: CustomPaint(
              painter: _MapPainter(),
              child: Container(color: const Color(0xFFF0EEF2)),
            ),
          ),

          // Rider position indicator (animated)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.52,
            top: MediaQuery.of(context).size.height * 0.45,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.iosBlue.withOpacity(0.1 + 0.1 * _pulseCtrl.value),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.iosBlue,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x4D007AFF), blurRadius: 8, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),

          // Floating top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 64,
                color: Colors.white.withOpacity(0.88),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      color: AppColors.textPrimary,
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Live Tracking',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 22, color: AppColors.iosBlue),
                      onPressed: _subscribeToLocationUpdates,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 30, offset: Offset(0, -8))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  GestureDetector(
                    onTap: () => setState(() => _sheetExpanded = !_sheetExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.separator,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedBuilder(
                                          animation: _pulseCtrl,
                                          builder: (_, __) => Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: AppColors.success.withOpacity(0.5 + 0.5 * _pulseCtrl.value),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(_status,
                                            style: GoogleFonts.inter(
                                                fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_price · ${widget.packageId}',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textQuaternary, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            // Call button
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.bgSecondary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.call_rounded, size: 20, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Arriving in ~$_eta · $_distance away',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),

                        // Extended info
                        if (_sheetExpanded) ...[
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.separator, height: 1),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: AppColors.bgSecondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person_rounded, size: 28, color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_riderName,
                                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                                            const SizedBox(width: 2),
                                            Text(_riderRating,
                                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(_vehicle,
                                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _RouteInfo(pickup: _pickup, dropoff: _dropoff),
                        ],
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteInfo extends StatelessWidget {
  final String pickup;
  final String dropoff;

  const _RouteInfo({required this.pickup, required this.dropoff});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textPrimary, width: 2),
              ),
            ),
            Container(width: 1.5, height: 36, color: AppColors.separator),
            Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PICKUP', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textQuaternary, letterSpacing: 0.8)),
                  const SizedBox(height: 2),
                  Text(pickup, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DROP-OFF', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textQuaternary, letterSpacing: 0.8)),
                  const SizedBox(height: 2),
                  Text(dropoff, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF0EEF2);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final roadPaint = Paint()..color = Colors.white..strokeWidth = 12..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final minorRoadPaint = Paint()..color = Colors.white..strokeWidth = 6..style = PaintingStyle.stroke;

    // Major roads
    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.35), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.65), roadPaint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), roadPaint);

    // Minor roads
    for (var i = 1; i < 8; i++) {
      canvas.drawLine(Offset(0, size.height * i / 8), Offset(size.width, size.height * i / 8), minorRoadPaint);
    }
    for (var i = 1; i < 6; i++) {
      canvas.drawLine(Offset(size.width * i / 6, 0), Offset(size.width * i / 6, size.height), minorRoadPaint);
    }

    // Route line
    final routePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final routePath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.72)
      ..cubicTo(
        size.width * 0.3, size.height * 0.65,
        size.width * 0.55, size.height * 0.5,
        size.width * 0.6, size.height * 0.38,
      )
      ..cubicTo(
        size.width * 0.65, size.height * 0.26,
        size.width * 0.7, size.height * 0.2,
        size.width * 0.75, size.height * 0.18,
      );
    canvas.drawPath(routePath, routePaint);

    // Pins
    final pickupPaint = Paint()..color = AppColors.textPrimary;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.72), 10, pickupPaint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.72), 5, Paint()..color = Colors.white);

    final dropoffPaint = Paint()..color = AppColors.accent;
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.18), 12, dropoffPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.18), 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_MapPainter old) => false;
}
