import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/opright_input.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        // Extract clean message from ApiException(statusCode): message format
        final match = RegExp(r'ApiException\(\d*\): (.+)').firstMatch(msg);
        if (match != null) msg = match.group(1)!;
        msg = msg.replaceAll('Exception: ', '');
        // Friendly message for invalid credentials
        if (msg.toLowerCase().contains('invalid credentials') ||
            msg.toLowerCase().contains('unauthorized')) {
          msg = 'Incorrect email or password. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Atmospheric glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.iosBlue.withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),
                          // OPRIGHT wordmark
                          Text(
                            'OPRIGHT',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome back.',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.21,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue.',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Email field
                          OprightInput(
                            hint: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            controller: _emailController,
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              size: 22,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password field
                          OprightInput(
                            hint: 'Password',
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            controller: _passwordController,
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 22,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              return null;
                            },
                            onSubmitted: (_) => _login(),
                          ),
                          const SizedBox(height: 10),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () =>
                                  context.push('/auth/forgot-password'),
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Sign In button
                          SizedBox(
                            height: 56,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          // Divider + social buttons removed (Apple/Google sign-in not yet supported)

                          const SizedBox(height: 32),
                          // Footer
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: AppColors.textTertiary,
                                  ),
                                  children: [
                                    const TextSpan(
                                        text: "Don't have an account? "),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () =>
                                            context.push('/auth/register'),
                                        child: Text(
                                          'Sign up',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
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
                          ),
                        ],
                      ),
                ),
              ),
            ),
          ],
      ),
    );
  }
}
