import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class DocumentsVerificationScreen extends StatelessWidget {
  const DocumentsVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.accent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Documents & Verification',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(context).padding.bottom + 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verification status banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle),
                    child: const Icon(Icons.verified_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Account Verified',
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success)),
                        Text('All documents approved',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Identity'),
            const SizedBox(height: 8),
            _DocumentCard(
              icon: Icons.badge_rounded,
              title: "Driver's Licence",
              subtitle: 'Expires Dec 2026',
              status: _DocStatus.approved,
              onTap: () => _showUploadSheet(context, "Driver's Licence"),
            ),
            const SizedBox(height: 10),
            _DocumentCard(
              icon: Icons.person_rounded,
              title: 'National ID / NIN',
              subtitle: 'Verified',
              status: _DocStatus.approved,
              onTap: () => _showUploadSheet(context, 'National ID'),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Vehicle'),
            const SizedBox(height: 8),
            _DocumentCard(
              icon: Icons.two_wheeler_rounded,
              title: 'Vehicle Registration',
              subtitle: 'LG 293-AB · Expires Mar 2025',
              status: _DocStatus.expiringSoon,
              onTap: () => _showUploadSheet(context, 'Vehicle Registration'),
            ),
            const SizedBox(height: 10),
            _DocumentCard(
              icon: Icons.shield_rounded,
              title: 'Insurance Certificate',
              subtitle: 'Upload required',
              status: _DocStatus.pending,
              onTap: () => _showUploadSheet(context, 'Insurance Certificate'),
            ),
            const SizedBox(height: 10),
            _DocumentCard(
              icon: Icons.directions_car_rounded,
              title: 'Vehicle Photo',
              subtitle: 'Approved',
              status: _DocStatus.approved,
              onTap: () => _showUploadSheet(context, 'Vehicle Photo'),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Profile'),
            const SizedBox(height: 8),
            _DocumentCard(
              icon: Icons.camera_alt_rounded,
              title: 'Profile Photo',
              subtitle: 'Approved',
              status: _DocStatus.approved,
              onTap: () => _showUploadSheet(context, 'Profile Photo'),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.separator),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.textTertiary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Documents are reviewed within 24 hours. Contact support if your submission has been pending longer.',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                letterSpacing: 0.5)),
      );

  void _showUploadSheet(BuildContext context, String docName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.separator,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('Update $docName',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 24),
            _UploadOption(
              icon: Icons.camera_alt_rounded,
              label: 'Take Photo',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _UploadOption(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

enum _DocStatus { approved, pending, expiringSoon, rejected }

class _DocumentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final _DocStatus status;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case _DocStatus.approved:
        return AppColors.success;
      case _DocStatus.pending:
        return AppColors.textQuaternary;
      case _DocStatus.expiringSoon:
        return AppColors.warning;
      case _DocStatus.rejected:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (status) {
      case _DocStatus.approved:
        return 'Approved';
      case _DocStatus.pending:
        return 'Upload';
      case _DocStatus.expiringSoon:
        return 'Expiring Soon';
      case _DocStatus.rejected:
        return 'Rejected';
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case _DocStatus.approved:
        return Icons.check_circle_rounded;
      case _DocStatus.pending:
        return Icons.upload_rounded;
      case _DocStatus.expiringSoon:
        return Icons.warning_amber_rounded;
      case _DocStatus.rejected:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 8,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textTertiary)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_statusIcon, color: _statusColor, size: 14),
                  const SizedBox(width: 4),
                  Text(_statusLabel,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _UploadOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 16, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
