import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Returns the Material icon that best represents a rider's vehicle type.
IconData riderVehicleIcon(String? vehicleType) {
  switch (vehicleType?.toUpperCase()) {
    case 'BICYCLE':
      return Icons.directions_bike_rounded;
    case 'MOTORCYCLE':
      return Icons.two_wheeler_rounded;
    case 'VAN':
      return Icons.local_shipping_rounded;
    default:
      return Icons.delivery_dining_rounded;
  }
}

/// Human-friendly label for a rider's vehicle type.
String riderVehicleLabel(String? vehicleType) {
  switch (vehicleType?.toUpperCase()) {
    case 'BICYCLE':
      return 'Bicycle';
    case 'MOTORCYCLE':
      return 'Motorcycle';
    case 'VAN':
      return 'Van';
    default:
      return 'Rider';
  }
}

/// Pulsing map marker for a rider, showing an icon that matches their
/// vehicle type (bicycle / motorcycle / van).
class RiderVehicleMarker extends StatelessWidget {
  final String? vehicleType;
  final Animation<double> pulse;
  final Color color;
  final double innerSize;

  const RiderVehicleMarker({
    super.key,
    required this.vehicleType,
    required this.pulse,
    this.color = AppColors.accent,
    this.innerSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12 + 0.08 * pulse.value),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              riderVehicleIcon(vehicleType),
              color: Colors.white,
              size: innerSize * 0.55,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill showing a rider's vehicle icon + label (e.g. a chip under a
/// rider's name in tracking/delivery screens).
class RiderVehicleBadge extends StatelessWidget {
  final String? vehicleType;
  final Color color;
  const RiderVehicleBadge({
    super.key,
    required this.vehicleType,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(riderVehicleIcon(vehicleType), color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            riderVehicleLabel(vehicleType),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
