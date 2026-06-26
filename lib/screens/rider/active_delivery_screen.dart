import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
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

class _ActiveDeliveryScreenState extends ConsumerState<ActiveDeliveryScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _pulseCtrl;

  PackageModel? _package;
  bool _isLoading = true;
  String? _error;

  LatLng? _riderPosition;
  LatLng _mapCenter = const LatLng(6.4550, 3.3841); // fallback Lagos
  bool _centredOnRider = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _loadPackage();
    _startLocationReporting();
  }

  Future<void> _geocodePickupAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty && mounted) {
        final pos = LatLng(locations.first.latitude, locations.first.longitude);
        setState(() => _mapCenter = pos);
        try { _mapController.move(pos, 15); } catch (_) {}
      }
    } catch (_) {
      // geocoding failed — stay on Lagos fallback
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPackage() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final pkg = await PackageService().getPackageById(widget.packageId);
      if (mounted) {
        setState(() { _package = pkg; _isLoading = false; });
        // Centre map on pickup address while waiting for GPS
        _geocodePickupAddress(pkg.pickupAddress);
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceAll('Exception: ', ''); _isLoading = false; });
    }
  }

  Future<void> _startLocationReporting() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) return;

    await _reportLocation();
    _locationTimer = Timer.periodic(
      const Duration(seconds: 5), (_) => _reportLocation());
  }

  Future<void> _reportLocation() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 4),
      );
      final pos = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _riderPosition = pos;
          _mapCenter = pos;
        });
        // Only animate to rider position — afterwards map follows rider
        try { _mapController.move(pos, _centredOnRider ? _mapController.camera.zoom : 15); } catch (_) {}
        _centredOnRider = true;
      }
      await ApiClient.instance.put(
        ApiEndpoints.courierLocation(userId),
        data: {'lat': position.latitude, 'lng': position.longitude},
      );
    } catch (_) {}
  }

  void _openInMaps(String address) async {
    final encoded = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text('Couldn\'t load delivery',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(_error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textTertiary)),
                  const SizedBox(height: 24),
                  TrakaButton(label: 'Try Again', onPressed: _loadPackage),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final pkg = _package!;

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen map ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.traka.mobile',
                maxZoom: 19,
              ),
              MarkerLayer(markers: [
                // Rider position
                if (_riderPosition != null)
                  Marker(
                    point: _riderPosition!,
                    width: 52,
                    height: 52,
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent
                              .withValues(alpha: 0.15 + 0.1 * _pulseCtrl.value),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0x40FF6B00),
                                    blurRadius: 8,
                                    spreadRadius: 2)
                              ],
                            ),
                            child: const Icon(Icons.delivery_dining_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),
            ],
          ),

          // ── Top bar ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 56,
                color: Colors.white.withValues(alpha: 0.95),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      color: AppColors.textPrimary,
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            pkg.trackingNumber ?? 'Active Delivery',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                          Text(
                            pkg.status.replaceAll('_', ' '),
                            style: GoogleFonts.inter(
                                fontSize: 11, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    // Chat button
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      color: AppColors.accent,
                      onPressed: () =>
                          context.push('/customer/chat/${pkg.id}'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom sheet ──
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 24,
                      offset: Offset(0, -6))
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                  24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 20),

                  // Route
                  _RouteRow(
                    icon: Icons.radio_button_checked,
                    iconColor: AppColors.accent,
                    label: 'PICKUP FROM',
                    address: pkg.pickupAddress,
                    onNavigate: () => _openInMaps(pkg.pickupAddress),
                  ),
                  const _RouteLine(),
                  _RouteRow(
                    icon: Icons.location_on_rounded,
                    iconColor: AppColors.success,
                    label: 'DELIVER TO',
                    address: pkg.deliveryAddress,
                    onNavigate: () => _openInMaps(pkg.deliveryAddress),
                  ),
                  const SizedBox(height: 20),

                  // Package info strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _InfoChip(
                            icon: Icons.inventory_2_outlined,
                            label: pkg.packageSize ?? 'SMALL'),
                        const SizedBox(width: 16),
                        _InfoChip(
                            icon: Icons.access_time_rounded,
                            label: (pkg.deliverySpeed ?? 'STANDARD')
                                .replaceAll('_', ' ')),
                        const Spacer(),
                        if (pkg.totalAmount != null)
                          Text(
                            '₦${pkg.totalAmount!.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action button
                  _ActionButton(package: pkg, onDone: () {
                    ref.invalidate(authProvider);
                    context.go('/rider/jobs');
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action button (confirm pickup / confirm delivery) ────────────────────────
class _ActionButton extends StatefulWidget {
  final PackageModel package;
  final VoidCallback onDone;
  const _ActionButton({required this.package, required this.onDone});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _loading = false;

  Future<void> _confirmPickup() async {
    final pin = await _askPin(context, 'Enter Pickup PIN');
    if (pin == null) return;
    setState(() => _loading = true);
    try {
      await ApiClient.instance.post(
        ApiEndpoints.confirmPickup(widget.package.id),
        data: {'pin': pin},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pickup confirmed — heading to delivery!'),
          backgroundColor: AppColors.success,
        ));
        context.replace('/rider/active/${widget.package.id}');
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelivery() async {
    final pin = await _askPin(context, 'Enter Delivery PIN');
    if (pin == null) return;
    setState(() => _loading = true);
    try {
      await ApiClient.instance.post(
        ApiEndpoints.confirmDelivery(widget.package.id),
        data: {'pin': pin},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Delivery complete! Great job 🎉'),
          backgroundColor: AppColors.success,
        ));
        widget.onDone();
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e.replaceAll('Exception: ', '')),
      backgroundColor: AppColors.error,
    ));
  }

  Future<String?> _askPin(BuildContext ctx, String title) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofocus: true,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
              color: AppColors.textPrimary),
          decoration: InputDecoration(
            counterText: '',
            hintText: '------',
            hintStyle: GoogleFonts.inter(
                fontSize: 28, letterSpacing: 8, color: AppColors.textQuaternary),
            filled: true,
            fillColor: AppColors.bgSecondary,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text('Confirm',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.package.status;
    if (status == 'PENDING' || status == 'OUT_FOR_DELIVERY') {
      return TrakaButton(
        label: 'Confirm Pickup',
        loading: _loading,
        onPressed: _loading ? null : _confirmPickup,
      );
    } else if (status == 'IN_TRANSIT') {
      return TrakaButton(
        label: 'Confirm Delivery',
        loading: _loading,
        onPressed: _loading ? null : _confirmDelivery,
      );
    }
    return TrakaButton(
      label: 'Back to Jobs',
      variant: TrakaBtnVariant.secondary,
      onPressed: widget.onDone,
    );
  }
}

// ── Supporting widgets ───────────────────────────────────────────────────────
class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  final VoidCallback onNavigate;

  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
    required this.onNavigate,
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
                      fontWeight: FontWeight.w700,
                      color: AppColors.textQuaternary,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(address,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.navigation_rounded),
          color: AppColors.iosBlue,
          iconSize: 20,
          onPressed: onNavigate,
          tooltip: 'Open in Maps',
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
      padding: const EdgeInsets.only(left: 8, top: 3, bottom: 3),
      child: Container(width: 2, height: 20, color: AppColors.separator),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
      ],
    );
  }
}
