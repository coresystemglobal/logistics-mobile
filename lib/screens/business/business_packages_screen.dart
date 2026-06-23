import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class BusinessPackagesScreen extends StatefulWidget {
  const BusinessPackagesScreen({super.key});

  @override
  State<BusinessPackagesScreen> createState() => _BusinessPackagesScreenState();
}

class _BusinessPackagesScreenState extends State<BusinessPackagesScreen> {
  int _activeFilter = 0;

  static const _filters = ['All Items', 'In Transit', 'Delivered', 'Pending'];

  static const _packages = [
    _ShipmentData(
      tracking: 'TRK-8829-01',
      recipient: 'Alex Sterling',
      address: '452 Blue Harbor Dr, Miami',
      date: 'Oct 24, 2023',
      status: 'In Transit',
      cost: '₦42,500',
    ),
    _ShipmentData(
      tracking: 'TRK-9102-44',
      recipient: 'Sarah Jenkins',
      address: '1290 Oak St, San Francisco',
      date: 'Oct 23, 2023',
      status: 'Delivered',
      cost: '₦28,900',
    ),
    _ShipmentData(
      tracking: 'TRK-1102-99',
      recipient: 'Global Logics Co.',
      address: '77 Tech Plaza, Austin',
      date: 'Oct 23, 2023',
      status: 'Pending',
      cost: '₦156,000',
    ),
    _ShipmentData(
      tracking: 'TRK-0021-38',
      recipient: 'Marcus Vane',
      address: '88 Broadway, New York',
      date: 'Oct 22, 2023',
      status: 'Delivered',
      cost: '₦34,200',
    ),
    _ShipmentData(
      tracking: 'TRK-4412-50',
      recipient: 'Chioma Okafor',
      address: 'Lekki Phase 1, Lagos',
      date: 'Oct 22, 2023',
      status: 'In Transit',
      cost: '₦18,000',
    ),
    _ShipmentData(
      tracking: 'TRK-8820-11',
      recipient: 'Daniel Abiodun',
      address: 'Ikeja GRA, Lagos',
      date: 'Oct 21, 2023',
      status: 'Pending',
      cost: '₦22,400',
    ),
  ];

  List<_ShipmentData> get _filtered {
    if (_activeFilter == 0) return _packages;
    final label = _filters[_activeFilter];
    return _packages.where((p) => p.status == label).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

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
                  const Spacer(),
                  const Icon(Icons.notifications_outlined,
                      color: AppColors.textSecondary),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + actions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'All Shipments',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        const _IconBtn(icon: Icons.filter_list_rounded),
                        const SizedBox(width: 8),
                        const _IconBtn(icon: Icons.ios_share_rounded),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date picker row
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.separator.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 18, color: AppColors.textTertiary),
                          const SizedBox(width: 8),
                          Text(
                            'This Month',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.expand_more_rounded,
                              color: AppColors.textQuaternary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter chips
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => setState(() => _activeFilter = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: _activeFilter == i
                                  ? AppColors.accent
                                  : AppColors.bgPrimary,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _activeFilter == i
                                    ? AppColors.accent
                                    : AppColors.separator,
                              ),
                            ),
                            child: Text(
                              _filters[i],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _activeFilter == i
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats summary
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _StatChip(
                              dot: AppColors.textPrimary,
                              label: '124 Total'),
                          _VDivider(),
                          const _StatChip(
                              dot: AppColors.success, label: '89 Delivered'),
                          _VDivider(),
                          const _StatChip(
                              dot: AppColors.iosBlue, label: '12 Active'),
                          _VDivider(),
                          const _StatChip(
                              dot: AppColors.warning, label: '23 Pending'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Package list
                    if (items.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Text(
                            'No shipments found',
                            style: GoogleFonts.inter(
                                color: AppColors.textTertiary),
                          ),
                        ),
                      )
                    else
                      Container(
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
                            return Column(
                              children: [
                                _ShipmentRow(data: items[i]),
                                if (i < items.length - 1)
                                  Divider(
                                    height: 0.5,
                                    thickness: 0.5,
                                    color: AppColors.separator
                                        .withValues(alpha: 0.5),
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                              ],
                            );
                          }),
                        ),
                      ),

                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Load More',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.iosBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/customer/book'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.separator),
      ),
      child: Icon(icon, size: 20, color: AppColors.textSecondary),
    );
  }
}

class _StatChip extends StatelessWidget {
  final Color dot;
  final String label;
  const _StatChip({required this.dot, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 16, color: AppColors.separator);
  }
}

class _ShipmentRow extends StatelessWidget {
  final _ShipmentData data;
  const _ShipmentRow({required this.data});

  Color get _statusColor {
    switch (data.status) {
      case 'Delivered':
        return AppColors.success;
      case 'Pending':
        return AppColors.warning;
      default:
        return AppColors.iosBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.tracking,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.recipient,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.address,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textQuaternary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.date,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textQuaternary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    data.status,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.cost,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentData {
  final String tracking;
  final String recipient;
  final String address;
  final String date;
  final String status;
  final String cost;

  const _ShipmentData({
    required this.tracking,
    required this.recipient,
    required this.address,
    required this.date,
    required this.status,
    required this.cost,
  });
}
