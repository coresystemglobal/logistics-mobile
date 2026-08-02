import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/delivery_card.dart';
import '../../services/package_service.dart';
import '../../models/package_model.dart';

final _historyProvider = FutureProvider.autoDispose<List<PackageModel>>(
  (ref) => PackageService().getMyPackages(limit: 50),
);

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() =>
      _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Active', 'Delivered', 'Cancelled'];

  List<PackageModel> _filtered(List<PackageModel> pkgs) {
    switch (_filter) {
      case 'Active':
        return pkgs.where((p) => p.isActive).toList();
      case 'Delivered':
        return pkgs.where((p) => p.isDelivered).toList();
      case 'Cancelled':
        return pkgs.where((p) => p.isCancelled).toList();
      default:
        return pkgs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(_historyProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.bgPrimary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/customer/home'),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      Text(
                        'My Packages',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 24),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        final isActive = _filter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.accent
                                  : AppColors.bgSecondary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              f,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: packagesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accent, strokeWidth: 2),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      Text('Failed to load',
                          style: GoogleFonts.inter(
                              color: AppColors.textTertiary)),
                      TextButton(
                        onPressed: () => ref.invalidate(_historyProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (packages) {
                  final filtered = _filtered(packages);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox_outlined,
                              color: AppColors.textQuaternary, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No packages',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final pkg = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: DeliveryCard(
                          trackingNumber: pkg.trackingNumber ?? '',
                          recipientName: pkg.deliveryAddress,
                          status: pkg.status.toLowerCase(),
                          subtitle: pkg.createdAt != null
                              ? _formatDate(pkg.createdAt!)
                              : null,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
