import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../models/package_model.dart';
import '../../services/package_service.dart';

class FindingRiderScreen extends StatefulWidget {
  final String packageId;

  const FindingRiderScreen({super.key, required this.packageId});

  @override
  State<FindingRiderScreen> createState() => _FindingRiderScreenState();
}

class _FindingRiderScreenState extends State<FindingRiderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  Timer? _pollTimer;
  PackageModel? _package;
  String _statusText = 'Searching for a nearby rider…';

  final _packageService = PackageService();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _startPolling();
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
        setState(() => _statusText = 'Rider found! Taking you to tracking…');
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          context.go('/customer/track/${pkg.trackingNumber ?? widget.packageId}');
        }
      } else if (pkg.status == 'PENDING') {
        setState(() => _statusText = 'Searching for a nearby rider…');
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRider = _package?.riderId != null && _package!.riderId!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Pulse animation
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: hasRider
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.accent.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasRider ? Icons.check_circle_rounded : Icons.delivery_dining_rounded,
                    color: hasRider ? AppColors.success : AppColors.accent,
                    size: 72,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Text(
                hasRider ? 'Rider Assigned!' : 'Finding Your Rider',
                style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16, color: AppColors.textTertiary, height: 1.5),
              ),

              if (!hasRider) ...[
                const SizedBox(height: 32),
                // Animated dots
                _DotsLoader(),
              ],

              // Rider info card once assigned
              if (hasRider && _package?.rider != null) ...[
                const SizedBox(height: 32),
                _RiderCard(rider: _package!.rider!),
              ],

              const Spacer(),

              if (!hasRider)
                TrakaButton(
                  label: 'Cancel Search',
                  variant: TrakaBtnVariant.ghost,
                  onPressed: () => context.go('/customer/home'),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiderCard extends StatelessWidget {
  final Map<String, dynamic> rider;

  const _RiderCard({required this.rider});

  @override
  Widget build(BuildContext context) {
    final name = rider['name'] ?? rider['full_name'] ?? 'Your Rider';
    final phone = rider['phone'] ?? rider['phone_number'];
    final rating = (rider['rating'] as num?)?.toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accentLight,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'R',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.accent),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (phone != null)
                  Text(phone, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                if (rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsLoader extends StatefulWidget {
  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final step = (_ctrl.value * 3).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 10, height: 10,
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
