import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/welcome_walkthrough.dart';
import '../../providers/auth_provider.dart';

class BusinessDashboardScreen extends ConsumerStatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  ConsumerState<BusinessDashboardScreen> createState() =>
      _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState
    extends ConsumerState<BusinessDashboardScreen> {
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

  String _todayLabel() {
    final now = DateTime.now();
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final businessName = user?.businessName ?? 'Adeola Fashola';

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Sticky header
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeader(businessName: businessName),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      'Good morning, $businessName.',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _todayLabel(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Metrics strip
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    _MetricCard(
                      icon: Icons.local_shipping_rounded,
                      iconColor: AppColors.accent,
                      label: 'Active Shipments',
                      value: '12',
                    ),
                    SizedBox(width: 12),
                    _MetricCard(
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.success,
                      label: 'Delivered Today',
                      value: '8',
                    ),
                    SizedBox(width: 12),
                    _MetricCard(
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: AppColors.iosBlue,
                      label: 'Total Spend',
                      value: '₦94,200',
                    ),
                    SizedBox(width: 12),
                    _MetricCard(
                      icon: Icons.schedule_rounded,
                      iconColor: AppColors.warning,
                      label: 'Pending Payment',
                      value: '₦12,000',
                    ),
                    SizedBox(width: 16),
                  ],
                ),
              ),
            ),

            // Chart + Quick Actions + Deliveries
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Bar chart
                    _WeeklyChart(),
                    const SizedBox(height: 20),

                    // Quick actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _QuickAction(
                          icon: Icons.add_box_rounded,
                          label: 'New Shipment',
                          onTap: () => context.push('/customer/book'),
                        ),
                        _QuickAction(
                          icon: Icons.group_rounded,
                          label: 'My Team',
                          onTap: () {},
                        ),
                        _QuickAction(
                          icon: Icons.receipt_long_rounded,
                          label: 'Invoices',
                          onTap: () => context.push('/business/invoices'),
                        ),
                        _QuickAction(
                          icon: Icons.bar_chart_rounded,
                          label: 'Reports',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Active deliveries
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Deliveries (12)',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              context.push('/business/packages'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            padding: EdgeInsets.zero,
                          ),
                          icon: const Text(''),
                          label: Row(
                            children: [
                              Text(
                                'Manage All',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.accent,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: AppColors.accent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Delivery cards
                    const _DeliveryListItem(
                      trackingNumber: 'TRK-88293-NG',
                      recipient: 'Chioma Okafor',
                      statusLabel: 'In Transit',
                      statusColor: AppColors.iosBlue,
                      detail: 'ETA: 4:30 PM Today',
                      detailIcon: Icons.schedule_rounded,
                    ),
                    const SizedBox(height: 12),
                    const _DeliveryListItem(
                      trackingNumber: 'TRK-90122-NG',
                      recipient: 'Daniel Abiodun',
                      statusLabel: 'Processing',
                      statusColor: AppColors.warning,
                      detail: 'Warehouse, Ikeja',
                      detailIcon: Icons.location_on_rounded,
                    ),
                    const SizedBox(height: 12),
                    const _DeliveryListItem(
                      trackingNumber: 'TRK-44512-NG',
                      recipient: 'Zenith Bank HQ',
                      statusLabel: 'Arriving',
                      statusColor: AppColors.success,
                      detail: '0.5km away',
                      detailIcon: Icons.local_shipping_rounded,
                    ),
                    const SizedBox(height: 16),

                    // View all button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            context.push('/business/packages'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(
                              color: AppColors.accent, width: 2),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'View All Deliveries',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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

class _StickyHeader extends SliverPersistentHeaderDelegate {
  final String businessName;
  const _StickyHeader({required this.businessName});

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface.withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Opright Business',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          const Spacer(),
          // Notification
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.textSecondary,
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.separator.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Text(
              businessName.isNotEmpty ? businessName[0].toUpperCase() : 'B',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyHeader oldDelegate) =>
      oldDelegate.businessName != businessName;
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const Spacer(),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  static const _bars = [
    (label: 'M', pct: 0.40, today: false),
    (label: 'T', pct: 0.65, today: false),
    (label: 'W', pct: 0.85, today: false),
    (label: 'T', pct: 0.55, today: false),
    (label: 'F', pct: 0.95, today: false),
    (label: 'S', pct: 0.30, today: false),
    (label: 'S', pct: 0.75, today: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipments this week',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _bars.map((bar) {
                return _BarItem(
                  label: bar.label,
                  pct: bar.pct,
                  isToday: bar.today,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.separator),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ChartLegend(color: AppColors.success, label: 'Delivered'),
              _ChartLegend(color: AppColors.iosBlue, label: 'In Transit'),
              _ChartLegend(color: AppColors.warning, label: 'Pending'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final String label;
  final double pct;
  final bool isToday;

  const _BarItem({
    required this.label,
    required this.pct,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, v, __) => Container(
                width: 10,
                height: 96 * v,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.accent
                      : AppColors.accent.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday ? AppColors.accent : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.bgPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.accent, size: 24),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryListItem extends StatelessWidget {
  final String trackingNumber;
  final String recipient;
  final String statusLabel;
  final Color statusColor;
  final String detail;
  final IconData detailIcon;

  const _DeliveryListItem({
    required this.trackingNumber,
    required this.recipient,
    required this.statusLabel,
    required this.statusColor,
    required this.detail,
    required this.detailIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trackingNumber,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'To: $recipient',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: AppColors.separator.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(detailIcon,
                  size: 16, color: AppColors.textQuaternary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  detail,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textQuaternary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
