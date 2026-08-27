import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  void _showEditProfile(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).user;
    final firstNameCtrl =
        TextEditingController(text: user?.firstName ?? '');
    final surnameCtrl =
        TextEditingController(text: user?.surname ?? '');
    final phoneCtrl =
        TextEditingController(text: user?.phone ?? '');
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.separator,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Profile',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _EditField(label: 'First Name', controller: firstNameCtrl),
              const SizedBox(height: 14),
              _EditField(label: 'Surname', controller: surnameCtrl),
              const SizedBox(height: 14),
              _EditField(
                label: 'Phone Number',
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() => saving = true);
                          try {
                            await ref
                                .read(authProvider.notifier)
                                .updateProfile(
                                  firstName: firstNameCtrl.text.trim(),
                                  surname: surnameCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                );
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            setState(() => saving = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(e
                                      .toString()
                                      .replaceAll('Exception: ', '')),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text('Save Changes',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final initials = [
      user?.firstName.isNotEmpty == true ? user!.firstName[0] : '',
      user?.surname.isNotEmpty == true ? user!.surname[0] : '',
    ].join().toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.bgPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 64,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials.isEmpty ? '?' : initials,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'OPRIGHT',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.accentDark,
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Profile card
                    GestureDetector(
                      onTap: () => _showEditProfile(context, ref),
                      child: Container(
                      padding: const EdgeInsets.all(16),
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
                              initials.isEmpty ? '?' : initials,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? '—',
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.phone ?? user?.email ?? '—',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textQuaternary,
                          ),
                        ],
                      ),
                    ),
                    ),
                    const SizedBox(height: 24),

                    // Account section
                    const _SectionHeader(label: 'Account'),
                    const SizedBox(height: 8),
                    _SettingsGroup(items: [
                      _SettingsRow(
                        icon: Icons.manage_accounts_rounded,
                        label: 'Edit Profile',
                        onTap: () => _showEditProfile(context, ref),
                      ),
                      _SettingsRow(
                        icon: Icons.lock_rounded,
                        label: 'Change Password',
                        onTap: () => context.push('/customer/change-password'),
                      ),
                      _SettingsRow(
                        icon: Icons.notifications_active_rounded,
                        label: 'Notification Preferences',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Delivery section
                    const _SectionHeader(label: 'Delivery'),
                    const SizedBox(height: 8),
                    _SettingsGroup(items: [
                      _SettingsRow(
                        icon: Icons.import_contacts_rounded,
                        label: 'Address Book',
                        onTap: () => context.push('/customer/address-book'),
                      ),
                      _SettingsRow(
                        icon: Icons.inventory_2_rounded,
                        label: 'My Packages',
                        onTap: () => context.push('/customer/history'),
                      ),
                      _SettingsRow(
                        icon: Icons.share_rounded,
                        label: 'Referral Code',
                        trailing: Text(
                          '20% OFF',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                        onTap: () => context.push('/customer/referral'),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Payments section
                    const _SectionHeader(label: 'Payments'),
                    const SizedBox(height: 8),
                    _SettingsGroup(items: [
                      _SettingsRow(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Wallet',
                        trailing: Text(
                          '₦45,000.00',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        onTap: () => context.push('/customer/wallet'),
                      ),
                      _SettingsRow(
                        icon: Icons.history_rounded,
                        label: 'Transaction History',
                        onTap: () => context.push('/customer/transactions'),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Legal & Support section
                    const _SectionHeader(label: 'Legal & Support'),
                    const SizedBox(height: 8),
                    _SettingsGroup(items: [
                      _SettingsRow(
                        icon: Icons.help_rounded,
                        label: 'FAQ / Help Center',
                        onTap: () => context.push('/faq'),
                      ),
                      _SettingsRow(
                        icon: Icons.gavel_rounded,
                        label: 'Terms of Service',
                        onTap: () {},
                      ),
                      _SettingsRow(
                        icon: Icons.shield_rounded,
                        label: 'Privacy Policy',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 32),

                    // Sign out
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsRow> items;
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
                    top: i == 0
                        ? const Radius.circular(16)
                        : Radius.zero,
                    bottom: i == items.length - 1
                        ? const Radius.circular(16)
                        : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(item.icon,
                            color: AppColors.accent, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.label,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (item.trailing != null) ...[
                          item.trailing!,
                          const SizedBox(width: 4),
                        ],
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textQuaternary,
                          size: 20,
                        ),
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

class _SettingsRow {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _EditField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(autocorrect: false, enableSuggestions: false, 
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
              fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgSecondary,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
