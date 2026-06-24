import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../providers/auth_provider.dart';
import '../../services/package_service.dart';
import '../../models/package_model.dart';

class ActiveDeliveryScreen extends ConsumerStatefulWidget {
  final String packageId;
  const ActiveDeliveryScreen({super.key, required this.packageId});

  @override
  ConsumerState<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends ConsumerState<ActiveDeliveryScreen> {
  PackageModel? _package;
  bool _isLoading = true;
  String? _error;

  Timer? _locationTimer;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _loadPackage();
    _startLocationReporting();
  }

  Future<void> _loadPackage() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final pkg = await PackageService().getPackageById(widget.packageId);
      if (mounted) setState(() { _package = pkg; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _startLocationReporting() async {
    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return;
    }

    _locationPermissionGranted = true;

    // Send location immediately, then every 5 seconds while this screen is active
    await _reportLocation();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) => _reportLocation());
  }

  Future<void> _reportLocation() async {
    if (!_locationPermissionGranted) return;
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 4),
      );
      await ApiClient.instance.put(
        ApiEndpoints.courierLocation(userId),
        data: {'lat': position.latitude, 'lng': position.longitude},
      );
    } catch (_) {
      // Non-fatal — next tick will retry
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _loadPackage)
              : _DeliveryView(package: _package!),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 64,
            color: AppColors.bgPrimary,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 36),
                    ),
                    const SizedBox(height: 20),
                    Text('Couldn\'t load delivery',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        )),
                    const SizedBox(height: 8),
                    Text(error,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        )),
                    const SizedBox(height: 24),
                    TrakaButton(label: 'Try Again', onPressed: onRetry),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryView extends StatelessWidget {
  final PackageModel package;
  const _DeliveryView({required this.package});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Map placeholder
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              Container(
                color: const Color(0xFFE8EDF2),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.bgPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.map_rounded,
                          color: AppColors.accent,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Navigation Map',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Safe area + back button + chat
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.bgPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0x14000000), blurRadius: 8),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AppColors.textPrimary,
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.bgPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0x14000000), blurRadius: 8),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          color: AppColors.accent,
                          onPressed: () =>
                              context.push('/customer/chat/${package.id}'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Status pill
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.bgSecondary.withValues(alpha: 0.9),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        package.trackingNumber ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        package.status.replaceAll('_', ' '),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Delivery info card
        Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          decoration: const BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteRow(
                  icon: Icons.radio_button_checked,
                  iconColor: AppColors.accent,
                  label: 'PICKUP FROM',
                  address: package.pickupAddress,
                ),
                const _RouteLine(),
                _RouteRow(
                  icon: Icons.location_on_rounded,
                  iconColor: AppColors.success,
                  label: 'DELIVER TO',
                  address: package.deliveryAddress,
                ),
                const SizedBox(height: 24),

                if (package.status == 'PENDING')
                  TrakaButton(label: 'Arrived at Pickup', onPressed: () {})
                else if (package.status == 'PICKED_UP' ||
                    package.status == 'IN_TRANSIT')
                  TrakaButton(label: 'Submit Proof of Delivery', onPressed: () {})
                else
                  TrakaButton(label: 'Return to Jobs', onPressed: () => context.pop()),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textQuaternary,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 2),
              Text(address,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
      child: Container(width: 2, height: 24, color: AppColors.separator),
    );
  }
}
