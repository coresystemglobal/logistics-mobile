import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../core/widgets/traka_input.dart';
import '../../providers/auth_provider.dart';

class RegisterBusinessScreen extends ConsumerStatefulWidget {
  const RegisterBusinessScreen({super.key});

  @override
  ConsumerState<RegisterBusinessScreen> createState() =>
      _RegisterBusinessScreenState();
}

class _RegisterBusinessScreenState extends ConsumerState<RegisterBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _contactPersonCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cacNumberCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _termsAccepted = false;
  bool _termsError = false;

  String _normalizePhone(String phone) {
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (phone.startsWith('+')) return phone;
    if (phone.startsWith('234')) return '+$phone';
    if (phone.startsWith('0')) return '+234${phone.substring(1)}';
    return '+234$phone';
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _contactPersonCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cacNumberCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      setState(() => _termsError = true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final email = _emailCtrl.text.trim();
      await ref.read(authProvider.notifier).registerBusiness(
            businessName: _businessNameCtrl.text.trim(),
            contactPerson: _contactPersonCtrl.text.trim(),
            email: email,
            phone: _normalizePhone(_phoneCtrl.text.trim()),
            address: _addressCtrl.text.trim(),
            password: _passwordCtrl.text,
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
            // Header with step indicator
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
                                ? AppColors.iosBlue
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
                          color: AppColors.iosBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your\nBusiness Account.',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ship smarter, scale faster with TRAKA.',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      TrakaInput(
                        hint: 'Business Name',
                        controller: _businessNameCtrl,
                        prefixIcon: const Icon(Icons.business_rounded,
                            color: AppColors.textTertiary, size: 20),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TrakaInput(
                        hint: 'Contact Person',
                        controller: _contactPersonCtrl,
                        prefixIcon: const Icon(Icons.person_outline_rounded,
                            color: AppColors.textTertiary, size: 20),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TrakaInput(
                        hint: 'Business Email',
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
                        hint: 'Business Phone',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: AppColors.textTertiary, size: 20),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TrakaInput(
                        hint: 'Business Address',
                        controller: _addressCtrl,
                        prefixIcon: const Icon(Icons.location_on_outlined,
                            color: AppColors.textTertiary, size: 20),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TrakaInput(
                        hint: 'CAC Registration Number',
                        controller: _cacNumberCtrl,
                        prefixIcon: const Icon(Icons.description_outlined,
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
                          if (v!.length < 8) return 'Minimum 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Verification note
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.iosBlue.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.iosBlue.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_outlined,
                                color: AppColors.iosBlue, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your CAC number is used to verify your business. This may take up to 24 hours.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.iosBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _termsAccepted,
                              onChanged: (v) => setState(() {
                                _termsAccepted = v ?? false;
                                if (_termsAccepted) _termsError = false;
                              }),
                              activeColor: AppColors.iosBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textTertiary,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.iosBlue,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => context.push('/terms-of-service'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_termsError) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 34),
                          child: Text(
                            'You must accept the Terms of Service',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      TrakaButton(
                        label: 'Create Business Account',
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
                              const TextSpan(text: 'Already have an account? '),
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
