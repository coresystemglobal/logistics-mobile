import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _newJobs = true;
  bool _jobUpdates = true;
  bool _payouts = true;
  bool _promotions = false;
  bool _appSounds = true;
  bool _vibration = true;
  bool _emailDigest = false;
  bool _smsAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.accent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notification Preferences',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(label: 'Delivery Alerts'),
            const SizedBox(height: 8),
            _ToggleGroup(items: [
              _ToggleItem(
                icon: Icons.work_rounded,
                label: 'New Job Requests',
                subtitle: 'Get notified when a new job is available',
                value: _newJobs,
                onChanged: (v) => setState(() => _newJobs = v),
              ),
              _ToggleItem(
                icon: Icons.update_rounded,
                label: 'Job Status Updates',
                subtitle: 'Pickup confirmed, delivered, etc.',
                value: _jobUpdates,
                onChanged: (v) => setState(() => _jobUpdates = v),
              ),
            ]),
            const SizedBox(height: 24),
            _SectionHeader(label: 'Payments'),
            const SizedBox(height: 8),
            _ToggleGroup(items: [
              _ToggleItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Payout Notifications',
                subtitle: 'When earnings are transferred',
                value: _payouts,
                onChanged: (v) => setState(() => _payouts = v),
              ),
              _ToggleItem(
                icon: Icons.campaign_rounded,
                label: 'Promotions & Bonuses',
                subtitle: 'Bonus offers and incentive alerts',
                value: _promotions,
                onChanged: (v) => setState(() => _promotions = v),
              ),
            ]),
            const SizedBox(height: 24),
            _SectionHeader(label: 'Sound & Vibration'),
            const SizedBox(height: 8),
            _ToggleGroup(items: [
              _ToggleItem(
                icon: Icons.volume_up_rounded,
                label: 'App Sounds',
                subtitle: 'Sound effects for alerts',
                value: _appSounds,
                onChanged: (v) => setState(() => _appSounds = v),
              ),
              _ToggleItem(
                icon: Icons.vibration_rounded,
                label: 'Vibration',
                subtitle: 'Vibrate for incoming jobs',
                value: _vibration,
                onChanged: (v) => setState(() => _vibration = v),
              ),
            ]),
            const SizedBox(height: 24),
            _SectionHeader(label: 'Other Channels'),
            const SizedBox(height: 8),
            _ToggleGroup(items: [
              _ToggleItem(
                icon: Icons.email_rounded,
                label: 'Email Digest',
                subtitle: 'Weekly earnings summary via email',
                value: _emailDigest,
                onChanged: (v) => setState(() => _emailDigest = v),
              ),
              _ToggleItem(
                icon: Icons.sms_rounded,
                label: 'SMS Alerts',
                subtitle: 'Critical alerts via SMS',
                value: _smsAlerts,
                onChanged: (v) => setState(() => _smsAlerts = v),
              ),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preferences saved'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Save Preferences',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                letterSpacing: 0.5)),
      );
}

class _ToggleItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}

class _ToggleGroup extends StatelessWidget {
  final List<_ToggleItem> items;
  const _ToggleGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label,
                              style: GoogleFonts.inter(
                                  fontSize: 15, color: AppColors.textPrimary)),
                          Text(item.subtitle,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: item.value,
                      onChanged: item.onChanged,
                      activeColor: AppColors.accent,
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                const Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: AppColors.separator,
                    indent: 66),
            ],
          );
        }),
      ),
    );
  }
}
