import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../core/widgets/traka_input.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _surnameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final email = _emailCtrl.text.trim();
      await ref.read(authProvider.notifier).registerCustomer(
            firstName: _firstNameCtrl.text.trim(),
            surname: _surnameCtrl.text.trim(),
            email: email,
            phone: _phoneCtrl.text.trim(),
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
                            child: TrakaInput(
                              hint: 'First name',
                              controller: _firstNameCtrl,
                              textInputAction: TextInputAction.next,
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TrakaInput(
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

                      TrakaInput(
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

                      TrakaInput(
                        hint: 'Phone number',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        controller: _phoneCtrl,
                        prefixIcon: const Icon(Icons.phone_outlined, size: 22),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      TrakaInput(
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
                      const SizedBox(height: 12),

                      Text(
                        'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textQuaternary,
                          height: 1.5,
                        ),
                      ),
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
                  TrakaButton(
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
