import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

typedef _Step = ({String emoji, String title, String description});

const _customerSteps = <_Step>[
  (
    emoji: '🎉',
    title: 'Welcome to Opright!',
    description:
        "You're all set. OPRIGHT connects you with riders who deliver your packages fast, anywhere in Nigeria.",
  ),
  (
    emoji: '📦',
    title: 'Book a delivery',
    description:
        "Tap 'Book Delivery' on your home screen to create a package request. We'll match you with a nearby rider instantly.",
  ),
  (
    emoji: '📍',
    title: 'Track in real time',
    description:
        'Follow your delivery live — from pickup to your doorstep — right from the app.',
  ),
];

const _riderSteps = <_Step>[
  (
    emoji: '🏍️',
    title: 'Welcome to the team!',
    description:
        "You're now part of the Opright rider network. Start earning deliveries on your own schedule.",
  ),
  (
    emoji: '🟢',
    title: 'Go online to earn',
    description:
        'Toggle your status to Online from the dashboard to start seeing delivery requests near you.',
  ),
  (
    emoji: '💰',
    title: 'Track your earnings',
    description:
        'Accept jobs, complete deliveries, and watch your earnings grow. Check your wallet anytime.',
  ),
];

const _businessSteps = <_Step>[
  (
    emoji: '🏢',
    title: 'Welcome to Opright Business!',
    description:
        'Ship smarter, scale faster. Your business dashboard is ready to go.',
  ),
  (
    emoji: '🚚',
    title: 'Create a shipment',
    description:
        "Tap 'New Shipment' to book a delivery for your customers. Riders are dispatched instantly.",
  ),
  (
    emoji: '📊',
    title: 'Track everything',
    description:
        'Monitor all deliveries, manage your team, and download invoices — all from one place.',
  ),
];

List<_Step> _stepsFor(String role) {
  switch (role.toUpperCase()) {
    case 'RIDER':
      return _riderSteps;
    case 'BUSINESS_OWNER':
      return _businessSteps;
    default:
      return _customerSteps;
  }
}

/// Shows the welcome walkthrough dialog once per user (keyed by [userId]).
/// Safe to call from initState via addPostFrameCallback.
Future<void> showWelcomeWalkthrough(
  BuildContext context, {
  required String userId,
  required String role,
  String firstName = '',
}) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'opright_welcomed_$userId';
  if (prefs.getBool(key) == true) return;
  await prefs.setBool(key, true);

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _WelcomeDialog(
      steps: _stepsFor(role),
      role: role,
      firstName: firstName,
    ),
  );
}

class _WelcomeDialog extends StatefulWidget {
  final List<_Step> steps;
  final String role;
  final String firstName;

  const _WelcomeDialog({
    required this.steps,
    required this.role,
    required this.firstName,
  });

  @override
  State<_WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<_WelcomeDialog> {
  late final PageController _ctrl;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isLast => _page == widget.steps.length - 1;

  void _next() {
    if (_isLast) {
      Navigator.of(context).pop();
    } else {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _title(_Step step) {
    if (widget.role.toUpperCase() == 'RIDER' &&
        _page == 0 &&
        widget.firstName.isNotEmpty) {
      return 'Welcome, ${widget.firstName}!';
    }
    return step.title;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Skip button row
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Skip',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textQuaternary,
                ),
              ),
            ),
          ),

          // Slides
          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: widget.steps.length,
              itemBuilder: (_, i) {
                final step = widget.steps[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      Text(
                        step.emoji,
                        style: const TextStyle(fontSize: 56),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _title(step),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.steps.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.accent : AppColors.separator,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // CTA button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isLast ? 'Get Started' : 'Next',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
