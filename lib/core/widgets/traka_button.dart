import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum TrakaBtnVariant { primary, secondary, ghost, danger }

class TrakaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TrakaBtnVariant variant;
  final bool loading;
  final Widget? icon;
  final double height;

  const TrakaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TrakaBtnVariant.primary,
    this.loading = false,
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    final child = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _labelColor,
                ),
              ),
            ],
          );

    switch (variant) {
      case TrakaBtnVariant.primary:
        return ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: child,
        );
      case TrakaBtnVariant.secondary:
        return OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: child,
        );
      case TrakaBtnVariant.ghost:
        return TextButton(
          onPressed: loading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.iosBlue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: child,
        );
      case TrakaBtnVariant.danger:
        return ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: child,
        );
    }
  }

  Color get _labelColor {
    switch (variant) {
      case TrakaBtnVariant.primary:
      case TrakaBtnVariant.danger:
        return Colors.white;
      case TrakaBtnVariant.secondary:
        return AppColors.accent;
      case TrakaBtnVariant.ghost:
        return AppColors.iosBlue;
    }
  }
}
