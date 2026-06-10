import 'package:flutter/material.dart';

class AppColors {
  // TRAKA Brand
  static const Color accent = Color(0xFFFF6B00);
  static const Color accentLight = Color(0xFFFFF0E6);
  static const Color accentDark = Color(0xFFA04100);

  // Light backgrounds (primary theme)
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF2F2F7);
  static const Color bgTertiary = Color(0xFFE5E5EA);
  static const Color surface = Color(0xFFFFF8F6);
  static const Color surfaceContainer = Color(0xFFFFEAE1);
  static const Color surfaceContainerHigh = Color(0xFFFEE3D8);

  // Text hierarchy (light mode)
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF3A3A3C);
  static const Color textTertiary = Color(0xFF6D6D70);
  static const Color textQuaternary = Color(0xFFAEAEB2);

  // Status
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color iosBlue = Color(0xFF007AFF);

  // Package status
  static const Color statusPending = Color(0xFFFF9500);
  static const Color statusPickup = Color(0xFF007AFF);
  static const Color statusTransit = Color(0xFF0070EB);
  static const Color statusDelivered = Color(0xFF34C759);
  static const Color statusCancelled = Color(0xFFFF3B30);

  // Structural
  static const Color separator = Color(0xFFC6C6C8);
  static const Color outline = Color(0xFF8E7164);
  static const Color outlineVariant = Color(0xFFE2BFB0);

  // Dark mode surfaces
  static const Color darkBg = Color(0xFF1C1C1E);
  static const Color darkBgSecondary = Color(0xFF261812);
  static const Color darkCard = Color(0xFF2C2C2E);
  static const Color darkSurface = Color(0xFF3A3A3C);

  // Semantic aliases — backwards compat for existing screens
  static const Color bgDark = darkBg;
  static const Color primary = accent;
  static const Color primaryLight = Color(0xFFFF8C38);
  static const Color primaryDark = accentDark;
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = textQuaternary;
  static const Color bgCard = bgPrimary;
  static const Color bgCardLight = bgSecondary;
  static const Color info = iosBlue;
  static const Color divider = separator;
  static const Color border = outlineVariant;

  static BoxDecoration get appleShadow => BoxDecoration(
        color: bgPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration cardDecoration({double radius = 16}) => BoxDecoration(
        color: bgPrimary,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      );

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'pickup':
      case 'assigned':
        return statusPickup;
      case 'in_transit':
      case 'transit':
        return statusTransit;
      case 'delivered':
        return statusDelivered;
      case 'cancelled':
        return statusCancelled;
      default:
        return textQuaternary;
    }
  }
}
