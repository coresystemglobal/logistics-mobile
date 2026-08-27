import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/opright_button.dart';
import '../../core/widgets/opright_input.dart';
import '../../providers/auth_provider.dart';

class RegisterCustomerScreen extends ConsumerStatefulWidget {
  const RegisterCustomerScreen({super.key});

  @override
  ConsumerState<RegisterCustomerScreen> createState() =>
      _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState
    extends ConsumerState<RegisterCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
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
    _firstNameCtrl.dispose();
    _surnameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _referralCtrl.dispose();
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
      await ref.read(authProvider.notifier).registerCustomer(
            firstName: _firstNameCtrl.text.trim(),
            surname: _surnameCtrl.text.trim(),
            email: email,
            phone: _normalizePhone(_phoneCtrl.text.trim()),
            password: _passwordCtrl.text,
            referralCode: _referralCtrl.text.trim().isNotEmpty
                ? _referralCtrl.text.trim()
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
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    'Step 2 of 3',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Create Account',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.21,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tell us about yourself.',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name row
                      Row(
                        children: [
                          Expanded(
                            child: OprightInput(
                              hint: 'First name',
                              controller: _firstNameCtrl,
                              textInputAction: TextInputAction.next,
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OprightInput(
                              hint: 'Surname',
                              controller: _surnameCtrl,
                              textInputAction: TextInputAction.next,
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      OprightInput(
                        hint: 'Email address',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        controller: _emailCtrl,
                        prefixIcon: const Icon(Icons.mail_outline_rounded,
                            size: 22),
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          if (!v!.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      OprightInput(
                        hint: 'Phone number',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        controller: _phoneCtrl,
                        prefixIcon: const Icon(Icons.phone_outlined, size: 22),
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          final normalized = _normalizePhone(v!.trim());
                          if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(normalized)) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      OprightInput(
                        hint: 'Password',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        controller: _passwordCtrl,
                        prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 22),
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          if (v!.length < 8) return 'Minimum 8 characters';
                          return null;
                        },
                        onSubmitted: (_) => _register(),
                      ),
                      const SizedBox(height: 14),

                      OprightInput(
                        hint: 'Referral code (optional)',
                        textInputAction: TextInputAction.next,
                        controller: _referralCtrl,
                        prefixIcon: const Icon(Icons.card_giftcard_outlined,
                            size: 22),
                      ),
                      const SizedBox(height: 12),

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
                              activeColor: AppColors.accent,
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
                                      color: AppColors.accent,
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
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  OprightButton(
                    label: 'Create Account',
                    loading: _isLoading,
                    onPressed: _isLoading ? null : _register,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
