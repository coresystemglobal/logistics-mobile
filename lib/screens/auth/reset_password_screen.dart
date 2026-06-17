import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/traka_button.dart';
import '../../core/widgets/traka_input.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final _authService = AuthService();

  @override
  void dispose() {
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(
        email: widget.email,
        code: _otpCtrl.text.trim(),
        newPassword: _passwordCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password reset successfully'),
          backgroundColor: AppColors.success,
        ));
        context.go('/auth/login');
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
              child: SingleChildScrollView(
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
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_reset_rounded,
                            color: AppColors.accent, size: 32),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Set new\npassword',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.21,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enter the code sent to ${widget.email}\nand choose a new password.',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppColors.textTertiary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),

                      TrakaInput(
                        hint: 'Reset code (OTP)',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        controller: _otpCtrl,
                        prefixIcon: const Icon(Icons.tag_rounded, size: 22),
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          if (v!.trim().length < 4) return 'Enter the full reset code';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      TrakaInput(
                        hint: 'New password',
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        controller: _passwordCtrl,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 22,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          if (v!.length < 8) return 'Minimum 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      TrakaInput(
                        hint: 'Confirm new password',
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        controller: _confirmCtrl,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          child: Icon(
                            _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 22,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          if (v != _passwordCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 32),

                      TrakaButton(
                        label: 'Reset Password',
                        loading: _isLoading,
                        onPressed: _isLoading ? null : _submit,
                      ),
                      const SizedBox(height: 24),
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
