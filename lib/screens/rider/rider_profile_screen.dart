import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/rider_model.dart';
import '../../providers/auth_provider.dart';
import '../../screens/rider/notification_preferences_screen.dart';
import '../../screens/rider/documents_verification_screen.dart';
import '../../screens/rider/payout_settings_screen.dart';
import '../../services/rider_service.dart';

final _riderProfileProvider = FutureProvider.autoDispose<RiderModel>(
  (_) => RiderService().getProfile(),
);

class RiderProfileScreen extends ConsumerStatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  ConsumerState<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends ConsumerState<RiderProfileScreen> {
  bool _isOnline = false; // initialized from profile on load
  bool _togglingStatus = false;

  @override
  void initState() {
    super.initState();
    // Read initial status from already-loaded rider profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rider = ref.read(_riderProfileProvider).valueOrNull;
      if (rider != null && mounted) {
        setState(() => _isOnline = rider.isAvailable || rider.status == 'AVAILABLE');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final riderAsync = ref.watch(_riderProfileProvider);
    final initials = [
      user?.firstName.isNotEmpty == true ? user!.firstName[0] : 'R',
      user?.surname.isNotEmpty == true ? user!.surname[0] : '',
    ].join().toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'TRAKA',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.accentLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.accent,
                                    width: 3,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initials,
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: _isOnline
                                        ? AppColors.success
                                        : AppColors.textQuaternary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.bgPrimary, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: riderAsync.when(
                              loading: () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user?.fullName ?? 'Rider',
                                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  Text('Loading...', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                                ],
                              ),
                              error: (_, __) => Text(user?.fullName ?? 'Rider',
                                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              data: (rider) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    final online = rider.isAvailable || rider.status == 'AVAILABLE';
                                    if (_isOnline != online) setState(() => _isOnline = online);
                                  }
                                });
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user?.fullName ?? 'Rider',
                                        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      rider.uniqueId.isNotEmpty ? rider.uniqueId : rider.id,
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(children: [
                                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${rider.rating?.toStringAsFixed(1) ?? '—'} · ${rider.totalDeliveries ?? 0} deliveries',
                                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
                                      ),
                                    ]),
                                    const SizedBox(height: 2),
                                    Text(rider.vehicleType,
                                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary)),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? AppColors.success.withValues(alpha: 0.06)
                            : AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isOnline
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.separator,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isOnline
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: _isOnline
                                ? AppColors.success
                                : AppColors.textQuaternary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isOnline ? 'You\'re Online' : 'You\'re Offline',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _isOnline
                                      ? 'Visible to new delivery jobs'
                                      : 'Not receiving new jobs',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isOnline,
                            onChanged: _togglingStatus ? null : (v) async {
                              setState(() {
                                _isOnline = v;
                                _togglingStatus = true;
                              });
                              try {
                                await RiderService().updateStatus(
                                    v ? 'AVAILABLE' : 'OFFLINE');
                                await RiderService().updateAvailability(v);
                              } catch (_) {}
                              if (mounted) {
                                setState(() => _togglingStatus = false);
                              }
                            },
                            activeThumbColor: AppColors.success,
                            trackColor: WidgetStateProperty.resolveWith(
                              (s) => s.contains(WidgetState.selected)
                                  ? AppColors.success.withValues(alpha: 0.3)
                                  : AppColors.bgTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Account section
                    const _SectionLabel(label: 'Account'),
                    const SizedBox(height: 8),
                    _SettingsGroup(items: [
                      _Item(
                        icon: Icons.manage_accounts_rounded,
                        label: 'Edit Profile',
                        onTap: () {},
                      ),
                      _Item(
                        icon: Icons.lock_rounded,
                        label: 'Change Password',
                        onTap: () {},
                      ),
                      _Item(
                        icon: Icons.notifications_active_rounded,
                        label: 'Notification Preferences',
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen())),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Vehicle & Documents
                    const _SectionLabel(label: 'Rider Info'),
                    const SizedBox(height: 8),
                    _SettingsGroup(items: [
                      _Item(
                        icon: Icons.two_wheeler_rounded,
                        label: 'Vehicle Information',
                        subtitle: riderAsync.maybeWhen(
                          data: (r) => '${r.vehicleType} · ${r.licenseNumber ?? ""}',
                          orElse: () => 'Loading...',
                        ),
                        onTap: () {},
                      ),
                      _Item(
                        icon: Icons.badge_rounded,
                        label: 'Documents & Verification',
                        subtitle: 'License, Insurance',
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const DocumentsVerificationScreen())),
                      ),
                      _Item(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Payout Settings',
                        subtitle: 'GTB ****4821',
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PayoutSettingsScreen())),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Support
                    const _SectionLabel(label: 'Support'),
                    const SizedBox(height: 8),
                    _SettingsGroup(items: [
                      _Item(
                        icon: Icons.help_rounded,
                        label: 'Help Center',
                        onTap: () => context.push('/faq'),
                      ),
                      _Item(
                        icon: Icons.gavel_rounded,
                        label: 'Terms of Service',
                        onTap: () => context.push('/terms-of-service'),
                      ),
                    ]),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () =>
                            ref.read(authProvider.notifier).logout(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'App Version 2.4.0 (Build 108)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textQuaternary,
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  const _Item({required this.icon, required this.label, this.subtitle, required this.onTap});
}

class _SettingsGroup extends StatelessWidget {
  final List<_Item> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(16) : Radius.zero,
                    bottom: i == items.length - 1
                        ? const Radius.circular(16)
                        : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(item.icon, color: AppColors.accent, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (item.subtitle != null)
                                Text(
                                  item.subtitle!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textQuaternary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              if (i < items.length - 1)
                const Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: AppColors.separator,
                  indent: 52,
                ),
            ],
          );
        }),
      ),
    );
  }
}
