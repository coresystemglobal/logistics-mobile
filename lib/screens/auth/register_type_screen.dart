import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';

class RegisterTypeScreen extends StatefulWidget {
  const RegisterTypeScreen({super.key});

  @override
  State<RegisterTypeScreen> createState() => _RegisterTypeScreenState();
}

class _RegisterTypeScreenState extends State<RegisterTypeScreen> {
  String? _selectedType;

  static const _types = [
    _AccountType(
      id: 'customer',
      title: 'Personal',
      subtitle:
          'Track shipments, manage deliveries, and receive personal parcels with ease.',
      icon: Icons.person_outline_rounded,
      iconBg: AppColors.accentLight,
      iconColor: AppColors.accent,
      borderColor: AppColors.accent,
      selectedBg: Color(0xFFFFF1EB),
    ),
    _AccountType(
      id: 'rider',
      title: 'Rider',
      subtitle:
          'Deliver packages and earn on your schedule. Flexible hours, great pay.',
      icon: Icons.two_wheeler_rounded,
      iconBg: Color(0xFFE9F7EF),
      iconColor: AppColors.success,
      borderColor: AppColors.success,
      selectedBg: Color(0xFFEAF7EF),
    ),
    _AccountType(
      id: 'business',
      title: 'Business',
      subtitle:
          'Optimized logistics for enterprises. Bulk tracking, team access, and analytics.',
      icon: Icons.corporate_fare_rounded,
      iconBg: Color(0xFFD8E2FF),
      iconColor: Color(0xFF0058BC),
      borderColor: Color(0xFF0070EB),
      selectedBg: Color(0xFFEDF1FF),
    ),
  ];

  void _continue() {
    if (_selectedType == null) return;
    switch (_selectedType) {
      case 'customer':
        context.push('/auth/register/customer');
      case 'rider':
        context.push('/auth/register/rider');
      case 'business':
        context.push('/auth/register/business');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  Text(
                    'Step 1 of 3',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textQuaternary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Join TRAKA',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.21,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'How will you use TRAKA?',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ...List.generate(_types.length, (i) {
                      final type = _types[i];
                      final isSelected = _selectedType == type.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AccountTypeCard(
                          type: type,
                          isSelected: isSelected,
                          onTap: () =>
                              setState(() => _selectedType = type.id),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Container(
                          height: 2,
                          width: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Choose the account that best reflects\nyour primary usage.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textQuaternary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  AnimatedOpacity(
                    opacity: _selectedType != null ? 1.0 : 0.45,
                    duration: const Duration(milliseconds: 200),
                    child: TrakaButton(
                      label: 'Continue',
                      onPressed: _selectedType != null ? _continue : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textQuaternary,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => context.push('/auth/login'),
                            child: Text(
                              'Log in',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final _AccountType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? type.selectedBg : AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? type.borderColor : AppColors.separator,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: type.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(type.icon, color: type.iconColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    type.title,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.check_circle_rounded,
                  color: type.borderColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountType {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color borderColor;
  final Color selectedBg;

  const _AccountType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.borderColor,
    required this.selectedBg,
  });
}
