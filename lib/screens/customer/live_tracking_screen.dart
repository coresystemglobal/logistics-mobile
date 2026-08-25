import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/rider_vehicle_marker.dart';
import '../../models/package_model.dart';
import '../../services/package_service.dart';
import '../../services/real_time_service.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String packageId;
  const LiveTrackingScreen({super.key, required this.packageId});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();

  bool _sheetExpanded = false;
  late final AnimationController _pulseCtrl;

  PackageModel? _package;
  bool _loadingPackage = true;

  LatLng? _riderPosition;
  String _status = 'In Transit';
  String _eta = '--';
  String _distance = '--';

  // Default to Lagos centre; updates once the first location event arrives.
  static const _defaultCenter = LatLng(6.4550, 3.3841);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _loadPackage();
    _subscribeToLocationUpdates();
  }

  Future<void> _loadPackage() async {
    try {
      final pkg = await PackageService().getPackageById(widget.packageId);
      if (mounted) setState(() { _package = pkg; _loadingPackage = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingPackage = false);
    }
  }

  void _subscribeToLocationUpdates() {
    final rt = RealTimeService.instance;
    rt.joinTracking(widget.packageId);

    rt.on('rider-location-update', (data) {
      if (!mounted || data == null) return;
      final d = data as Map<String, dynamic>;
      final lat = (d['latitude'] as num?)?.toDouble();
      final lng = (d['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) return;

      final newPos = LatLng(lat, lng);
      final newStatus = (d['package_status'] as String?) ?? _status;
      setState(() {
        _riderPosition = newPos;
        _status = newStatus.replaceAll('_', ' ');
      });

      _mapController.move(newPos, _mapController.camera.zoom);

      // Navigate to delivery complete when rider confirms delivery
      if (newStatus == 'DELIVERED' && mounted) {
        final pkg = _package;
        final rider = pkg?.rider;
        context.go(
          '/customer/delivery-complete/${widget.packageId}'
          '?riderId=${rider?['id'] ?? ''}'
          '&riderName=${Uri.encodeComponent(rider?['name'] ?? 'Rider')}'
          '&riderRating=${rider?['rating'] ?? 0}'
          '&recipientName=${Uri.encodeComponent(pkg?.recipientName ?? '')}',
        );
      }
    });

    rt.on('eta_update', (data) {
      if (!mounted || data == null) return;
      final d = data as Map<String, dynamic>;
      setState(() {
        _eta = d['eta']?.toString() ?? _eta;
        _distance = d['distance']?.toString() ?? _distance;
      });
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    RealTimeService.instance.leaveTracking(widget.packageId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingNumber = _package?.trackingNumber ?? widget.packageId;
    final pickupAddress = _package?.pickupAddress ?? '—';
    final dropoffAddress = _package?.deliveryAddress ?? '—';

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen OSM map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _riderPosition ?? _defaultCenter,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.traka.mobile',
                maxZoom: 19,
              ),
              if (_riderPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _riderPosition!,
                      width: 48,
                      height: 48,
                      child: RiderVehicleMarker(
                        vehicleType: _package?.rider?['vehicle_type'],
                        pulse: _pulseCtrl,
                        color: AppColors.iosBlue,
                      ),
                    ),
                  ],
                ),
            ],
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
                color: Colors.white.withValues(alpha: 0.92),
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
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // Connection indicator
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) => Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _riderPosition != null
                                ? AppColors.success.withValues(
                                    alpha: 0.5 + 0.5 * _pulseCtrl.value)
                                : AppColors.separator,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
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
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 30,
                    offset: Offset(0, -8),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  GestureDetector(
                    onTap: () =>
                        setState(() => _sheetExpanded = !_sheetExpanded),
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
                    padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      MediaQuery.of(context).padding.bottom + 16,
                    ),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.success.withValues(alpha: 0.12),
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
                                              color: AppColors.success
                                                  .withValues(alpha: 0.5 +
                                                      0.5 * _pulseCtrl.value),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _status,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    trackingNumber,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textQuaternary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _riderPosition == null
                              ? 'Waiting for rider location…'
                              : 'Arriving in ~$_eta · $_distance away',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),

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
                                child: Icon(
                                  riderVehicleIcon(_package?.rider?['vehicle_type']),
                                  size: 28,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _package != null ? 'Your Rider' : '—',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (_package?.rider?['vehicle_type'] != null)
                                      const SizedBox(height: 4),
                                    if (_package?.rider?['vehicle_type'] != null)
                                      RiderVehicleBadge(
                                        vehicleType: _package?.rider?['vehicle_type'],
                                        color: AppColors.iosBlue,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _RouteInfo(
                            pickup: pickupAddress,
                            dropoff: dropoffAddress,
                          ),
                        ],
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading chip while package data arrives
          if (_loadingPackage)
            Positioned(
              top: MediaQuery.of(context).padding.top + 76,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Loading…',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textTertiary),
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
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
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
                  Text('PICKUP',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textQuaternary,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 2),
                  Text(pickup,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DROP-OFF',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textQuaternary,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 2),
                  Text(dropoff,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
