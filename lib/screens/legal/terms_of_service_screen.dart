import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Terms of Service',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: June 17, 2026',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textQuaternary,
              ),
            ),
            const SizedBox(height: 24),
            _Section(
              number: '1',
              title: 'Acceptance of Terms',
              body:
                  'By creating an account or using the TRAKA platform, you confirm that you have read, understood, and agree to be bound by these Terms of Service and our Privacy Policy. If you do not agree, you may not use our services.',
            ),
            _Section(
              number: '2',
              title: 'Description of Service',
              body:
                  'TRAKA is a logistics and package-tracking platform that connects senders (customers and businesses) with delivery riders. We provide tools for booking deliveries, tracking packages in real time, managing fleets, and processing payments.\n\nWe reserve the right to modify, suspend, or discontinue any part of the service at any time with reasonable notice.',
            ),
            _Section(
              number: '3',
              title: 'User Accounts',
              body:
                  'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You must notify us immediately of any unauthorized use.\n\nYou must provide accurate, current, and complete information during registration and keep it up to date.',
            ),
            _Section(
              number: '4',
              title: 'User Responsibilities',
              body:
                  'You agree not to:\n\n• Use the platform for any unlawful purpose.\n• Transmit prohibited, hazardous, or illegal items through our delivery network.\n• Misrepresent the contents, value, or nature of packages.\n• Interfere with or disrupt the platform or servers.\n• Attempt to gain unauthorized access to any part of the service.',
            ),
            _Section(
              number: '5',
              title: 'Payments and Fees',
              body:
                  'All fees are displayed before you confirm a booking. By confirming, you authorize us to charge the stated amount. Fees are non-refundable except as outlined in our Refund Policy.',
            ),
            _Section(
              number: '6',
              title: 'Privacy Policy',
              body:
                  'Your use of TRAKA is also governed by our Privacy Policy, which describes how we collect, use, and protect your personal information.',
            ),
            _Section(
              number: '7',
              title: 'Limitation of Liability',
              body:
                  'To the fullest extent permitted by law, TRAKA shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the service.\n\nOur total liability shall not exceed the amount you paid us in the twelve months preceding the claim.',
            ),
            _Section(
              number: '8',
              title: 'Governing Law',
              body:
                  'These Terms shall be governed by the laws of the Federal Republic of Nigeria.',
            ),
            _Section(
              number: '9',
              title: 'Changes to Terms',
              body:
                  'We may update these Terms from time to time. We will notify you of significant changes by email or by posting a prominent notice in the app.',
            ),
            _Section(
              number: '10',
              title: 'Contact Us',
              body: 'If you have questions about these Terms, please contact us at support@traka.ng.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _Section({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. $title',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textTertiary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
