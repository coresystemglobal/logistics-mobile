import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../core/widgets/traka_input.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.requestPasswordReset(_emailCtrl.text.trim());
      if (mounted) {
        context.push('/auth/reset-password?email=${Uri.encodeComponent(_emailCtrl.text.trim())}');
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
        child: _sent ? _sentView() : _formView(),
      ),
    );
  }

  Widget _formView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_rounded,
                        color: AppColors.accent, size: 32),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Forgot\npassword?',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.21,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Enter your email address and we'll send\nyou a reset code.",
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      color: AppColors.textTertiary,
                      height: 1.47,
                    ),
                  ),
                  const SizedBox(height: 36),
                  TrakaInput(
                    hint: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    controller: _emailCtrl,
                    prefixIcon:
                        const Icon(Icons.mail_outline_rounded, size: 22),
                    validator: (v) {
                      if (v?.isEmpty == true) return 'Required';
                      if (!v!.contains('@')) return 'Invalid email';
                      return null;
                    },
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 28),
                  TrakaButton(
                    label: 'Send Reset Code',
                    loading: _isLoading,
                    onPressed: _isLoading ? null : _submit,
                  ),
                  const Spacer(),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Back to Sign In',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.iosBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sentView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Color(0xFFE9F7EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                color: AppColors.success, size: 48),
          ),
          const SizedBox(height: 28),
          Text(
            'Check your email',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We sent a reset code to\n${_emailCtrl.text.trim()}',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 17,
              color: AppColors.textTertiary,
              height: 1.47,
            ),
          ),
          const SizedBox(height: 48),
          TrakaButton(
            label: 'Back to Sign In',
            variant: TrakaBtnVariant.secondary,
            onPressed: () => context.go('/auth/login'),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _sent = false),
            child: Text(
              "Didn't receive it? Resend",
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.iosBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
