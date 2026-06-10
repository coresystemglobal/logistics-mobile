import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'status_badge.dart';

class DeliveryCard extends StatelessWidget {
  final String trackingNumber;
  final String recipientName;
  final String status;
  final String? subtitle;
  final VoidCallback? onTap;

  const DeliveryCard({
    super.key,
    required this.trackingNumber,
    required this.recipientName,
    required this.status,
    this.subtitle,
    this.onTap,
  });

  Color get _statusColor => AppColors.statusColor(status);

  IconData get _statusIcon {
    switch (status.toLowerCase()) {
      case 'in_transit':
      case 'transit':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.inventory_2_outlined;
      case 'pending':
        return Icons.schedule_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: _statusColor, width: 4),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_statusIcon, color: _statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trackingNumber,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    recipientName,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                StatusBadge(status: status, compact: true),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward,
                  color: AppColors.textQuaternary,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
