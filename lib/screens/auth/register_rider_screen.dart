import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../core/widgets/traka_input.dart';
import '../../providers/auth_provider.dart';

class RegisterRiderScreen extends ConsumerStatefulWidget {
  const RegisterRiderScreen({super.key});

  @override
  ConsumerState<RegisterRiderScreen> createState() => _RegisterRiderScreenState();
}

class _RegisterRiderScreenState extends ConsumerState<RegisterRiderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _vehiclePlateCtrl = TextEditingController();
  String _vehicleType = 'MOTORCYCLE';
  bool _isLoading = false;

  static const _vehicleTypes = [
    (type: 'BICYCLE', icon: Icons.pedal_bike_rounded, label: 'Bicycle'),
    (type: 'MOTORCYCLE', icon: Icons.two_wheeler_rounded, label: 'Motorcycle'),
    (type: 'VAN', icon: Icons.local_shipping_rounded, label: 'Van'),
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _surnameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _referralCtrl.dispose();
    _licenseCtrl.dispose();
    _vehiclePlateCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final email = _emailCtrl.text.trim();
      await ref.read(authProvider.notifier).registerRider(
            firstName: _firstNameCtrl.text.trim(),
            surname: _surnameCtrl.text.trim(),
            email: email,
            phone: _phoneCtrl.text.trim(),
            password: _passwordCtrl.text,
            vehicleType: _vehicleType,
            referralCode: _referralCtrl.text.trim().isNotEmpty
                ? _referralCtrl.text.trim()
                : null,
            licenseNumber: _licenseCtrl.text.trim().isNotEmpty
                ? _licenseCtrl.text.trim()
                : null,
            vehiclePlate: _vehiclePlateCtrl.text.trim().isNotEmpty
                ? _vehiclePlateCtrl.text.trim()
                : null,
          );
      if (mounted) {
        context.go('/auth/verify-email?email=${Uri.encodeComponent(email)}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              color: AppColors.bgPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textPrimary,
                    onPressed: () => context.pop(),
                  ),
                  // Step indicator
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final done = i < 2;
                        final active = i == 2;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: done || active ? 40 : 8,
                          height: 4,
                          decoration: BoxDecoration(
                            color: active || done
                                ? AppColors.success
                                : AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 3 of 3',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join TRAKA\nas a Rider.',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Start earning on your own schedule.',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name row
                      Row(
                        children: [
                          Expanded(
                            child: TrakaInput(
                              hint: 'First name',
                              controller: _firstNameCtrl,
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TrakaInput(
                              hint: 'Surname',
                              controller: _surnameCtrl,
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TrakaInput(
                        hint: 'Email address',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: AppColors.textTertiary, size: 20),
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          if (!v!.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TrakaInput(
                        hint: 'Phone number',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: AppColors.textTertiary, size: 20),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TrakaInput(
                        hint: 'Password',
                        controller: _passwordCtrl,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.textTertiary, size: 20),
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          if (v!.length < 8) return 'Min 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Vehicle type
                      Text(
                        'Vehicle Type',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: _vehicleTypes.map((v) {
                          final selected = _vehicleType == v.type;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _vehicleType = v.type),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.success.withOpacity(0.08)
                                      : AppColors.bgPrimary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.success
                                        : AppColors.separator,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      v.icon,
                                      color: selected
                                          ? AppColors.success
                                          : AppColors.textTertiary,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      v.label,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: selected
                                            ? AppColors.success
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_vehicleType != 'BICYCLE') ...[
                        const SizedBox(height: 14),
                        TrakaInput(
                          hint: 'License number',
                          controller: _licenseCtrl,
                          prefixIcon: const Icon(Icons.badge_outlined,
                              color: AppColors.textTertiary, size: 20),
                          validator: (v) => _vehicleType != 'BICYCLE' &&
                                  (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TrakaInput(
                          hint: 'Vehicle plate number',
                          controller: _vehiclePlateCtrl,
                          prefixIcon: const Icon(Icons.directions_car_outlined,
                              color: AppColors.textTertiary, size: 20),
                          validator: (v) => _vehicleType != 'BICYCLE' &&
                                  (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Referral
                      TrakaInput(
                        hint: 'Referral code (optional)',
                        controller: _referralCtrl,
                        prefixIcon: const Icon(Icons.card_giftcard_outlined,
                            color: AppColors.textTertiary, size: 20),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.success.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_rounded,
                                color: AppColors.success, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Both you and your referrer earn ₦1,000 bonus on your first delivery!',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      TrakaButton(
                        label: 'Create Rider Account',
                        loading: _isLoading,
                        onPressed: _register,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textTertiary,
                            ),
                            children: [
                              const TextSpan(
                                  text: 'Already have an account? '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => context.go('/auth/login'),
                                  child: Text(
                                    'Sign in',
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
