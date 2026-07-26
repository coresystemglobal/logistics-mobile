import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/delivery_card.dart';
import '../../core/widgets/welcome_walkthrough.dart';
import '../../providers/auth_provider.dart';
import '../../services/package_service.dart';
import '../../services/wallet_service.dart';
import '../../services/referral_service.dart';
import '../../models/package_model.dart';

final _customerPackagesProvider =
    FutureProvider.autoDispose<List<PackageModel>>(
  (ref) => PackageService().getMyPackages(limit: 5),
);

final _walletBalanceProvider = FutureProvider.autoDispose<double>(
  (_) async {
    final wallet = await WalletService().getBalance();
    return wallet.balance;
  },
);

final _referralStatsProvider = FutureProvider.autoDispose<int>(
  (_) async {
    final stats = await ReferralService().getStats();
    return stats.totalReferrals;
  },
);

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowWelcome());
  }

  Future<void> _maybeShowWelcome() async {
    final user = ref.read(authProvider).user;
    if (user == null || !mounted) return;
    await showWelcomeWalkthrough(
      context,
      userId: user.id,
      role: user.role,
      firstName: user.firstName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final packagesAsync = ref.watch(_customerPackagesProvider);
    final walletAsync = ref.watch(_walletBalanceProvider);
    final referralAsync = ref.watch(_referralStatsProvider);
    final firstName = authState.user?.firstName ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: CustomScrollView(
        slivers: [
          // Sticky header
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: AppColors.bgPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 64,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_greeting()}, $firstName',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(' 👋', style: TextStyle(fontSize: 18)),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: AppColors.textPrimary, size: 26),
                      onPressed: () => context.push('/notifications'),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats Strip
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _StatCard(
                        label: 'Active Deliveries',
                        value: packagesAsync.when(
                          data: (pkgs) => pkgs
                              .where((p) =>
                                  p.status.toLowerCase() == 'in_transit' ||
                                  p.status.toLowerCase() == 'pickup')
                              .length
                              .toString(),
                          loading: () => '—',
                          error: (_, __) => '0',
                        ),
                        icon: Icons.trending_flat_rounded,
                        iconColor: AppColors.accent,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Wallet Balance',
                        value: walletAsync.when(
                          data: (b) => '₦${b.toStringAsFixed(0)}',
                          loading: () => '—',
                          error: (_, __) => '₦0',
                        ),
                        valueColor: AppColors.success,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: 'Referral Points',
                        value: referralAsync.when(
                          data: (pts) => '$pts',
                          loading: () => '—',
                          error: (_, __) => '0',
                        ),
                        icon: Icons.star_rounded,
                        iconColor: AppColors.warning,
                      ),
                    ],
                  ),
                ),

                // Quick Actions Grid
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.45,
                    children: [
                      _QuickAction(
                        icon: Icons.inventory_2_outlined,
                        label: 'Book Delivery',
                        iconBg: AppColors.accentLight,
                        iconColor: AppColors.accent,
                        onTap: () => context.push('/customer/book'),
                      ),
                      _QuickAction(
                        icon: Icons.location_on_outlined,
                        label: 'Track Package',
                        iconBg: const Color(0xFFD8E2FF),
                        iconColor: const Color(0xFF0058BC),
                        onTap: () => context.go('/customer/history'),
                      ),
                      _QuickAction(
                        icon: Icons.calculate_outlined,
                        label: 'Get a Quote',
                        iconBg: const Color(0xFFE9F7EF),
                        iconColor: AppColors.success,
                        onTap: () => context.push('/customer/quote'),
                      ),
                      _QuickAction(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'My Wallet',
                        iconBg: const Color(0xFFFFF3E0),
                        iconColor: AppColors.warning,
                        onTap: () => context.go('/customer/wallet'),
                      ),
                    ],
                  ),
                ),

                // Promo Banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    width: double.infinity,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.warning],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 130,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '20% off your next 3 deliveries!',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  children: const [
                                    TextSpan(text: 'Use code '),
                                    TextSpan(
                                      text: 'TRAKA20',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextSpan(text: ' at checkout'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent Deliveries header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Deliveries',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/customer/history'),
                        child: Text(
                          'See all',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.iosBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Package list
          packagesAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accent, strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Could not load packages',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              ),
            ),
            data: (packages) {
              if (packages.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.inbox_outlined,
                              color: AppColors.textQuaternary, size: 44),
                          const SizedBox(height: 12),
                          Text(
                            'No deliveries yet',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Book your first delivery to get started',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final pkg = packages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: DeliveryCard(
                          trackingNumber: pkg.trackingNumber ?? '',
                          recipientName: pkg.deliveryAddress,
                          status: pkg.status.toLowerCase(),
                          onTap: () {
                            final status = pkg.status.toUpperCase();
                            if (status == 'PENDING' &&
                                (pkg.riderId == null || pkg.riderId!.isEmpty) &&
                                pkg.id.isNotEmpty) {
                              context.push('/customer/pending-delivery/${pkg.id}');
                            } else if (status == 'CANCELLED' && pkg.id.isNotEmpty) {
                              context.push('/customer/pending-delivery/${pkg.id}');
                            } else if (status == 'DELIVERED' && pkg.id.isNotEmpty) {
                              final rider = pkg.rider;
                              context.push(
                                '/customer/delivery-complete/${pkg.id}'
                                '?riderId=${rider?['id'] ?? ''}'
                                '&riderName=${Uri.encodeComponent(rider?['name'] ?? 'Rider')}'
                                '&riderRating=${rider?['rating'] ?? 0}'
                                '&recipientName=${Uri.encodeComponent(pkg.deliveryAddress)}',
                              );
                            } else if (pkg.trackingNumber != null &&
                                pkg.trackingNumber!.isNotEmpty) {
                              context.push(
                                  '/customer/track/${pkg.trackingNumber}?id=${pkg.id}');
                            }
                          },
                        ),
                      );
                    },
                    childCount: packages.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final Color? iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
              if (icon != null)
                Icon(icon, color: iconColor, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textQuaternary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
