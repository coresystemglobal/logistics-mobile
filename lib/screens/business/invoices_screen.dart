import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/invoice_model.dart';
import '../../services/invoice_service.dart';

final _invoicesProvider = FutureProvider.autoDispose<List<InvoiceModel>>(
  (_) => InvoiceService().getInvoices(),
);

final _filterProvider = StateProvider.autoDispose<String>((_) => 'all');

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(_invoicesProvider);
    final filter = ref.watch(_filterProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.bgPrimary,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.business_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text('TRAKA',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_rounded, color: AppColors.textPrimary),
                  onPressed: () => context.push('/notifications'),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + generate button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text('Invoices & Billing',
                              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _generateInvoice(context, ref),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text('Generate',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Outstanding balance card
                    invoicesAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (invoices) {
                        final outstanding = invoices
                            .where((i) => !i.isPaid)
                            .fold<double>(0, (sum, i) => sum + i.amount);
                        final overdueCount = invoices.where((i) => i.isOverdue).length;

                        return Column(
                          children: [
                            if (outstanding > 0)
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.bgPrimary,
                                  borderRadius: BorderRadius.circular(16),
                                  border: const Border(left: BorderSide(color: AppColors.accent, width: 4)),
                                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Outstanding Balance',
                                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary)),
                                          const SizedBox(height: 4),
                                          Text('₦${outstanding.toStringAsFixed(0)}',
                                              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.error)),
                                          Text('Current period',
                                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textQuaternary)),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      ),
                                      child: Text('Pay Now',
                                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ),

                            if (overdueCount > 0)
                              Container(
                                padding: const EdgeInsets.all(14),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF5F5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: const Border(left: BorderSide(color: AppColors.error, width: 4)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.warning_rounded, color: AppColors.error, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$overdueCount invoice${overdueCount > 1 ? 's are' : ' is'} overdue. Pay now to avoid service interruption.',
                                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                                          ),
                                          const SizedBox(height: 6),
                                          GestureDetector(
                                            onTap: () {},
                                            child: Text('Pay All Overdue',
                                                style: GoogleFonts.inter(
                                                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    // Filter tabs
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),

            // Filter tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterTabDelegate(
                filter: filter,
                onSelect: (v) => ref.read(_filterProvider.notifier).state = v,
              ),
            ),

            // Invoice list
            invoicesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error loading invoices: $err',
                    style: GoogleFonts.inter(color: AppColors.textSecondary))),
              ),
              data: (invoices) {
                final filtered = filter == 'all'
                    ? invoices
                    : invoices.where((i) => i.status.toLowerCase() == filter).toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('No ${filter == 'all' ? '' : filter} invoices',
                          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textTertiary)),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _InvoiceTile(invoice: filtered[index]),
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateInvoice(BuildContext context, WidgetRef ref) async {
    try {
      await InvoiceService().generateInvoice(tenantId: '', amount: 0);
      ref.invalidate(_invoicesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice generated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _FilterTabDelegate extends SliverPersistentHeaderDelegate {
  final String filter;
  final ValueChanged<String> onSelect;

  const _FilterTabDelegate({required this.filter, required this.onSelect});

  @override
  double get minExtent => 44;
  @override
  double get maxExtent => 44;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    const tabs = [('all', 'All'), ('pending', 'Pending'), ('paid', 'Paid'), ('overdue', 'Overdue')];
    return Container(
      color: AppColors.bgSecondary,
      child: Row(
        children: tabs.map((t) {
          final isActive = filter == t.$1;
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => onSelect(t.$1),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10, top: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? AppColors.accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  t.$2,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? AppColors.textPrimary : AppColors.textQuaternary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterTabDelegate old) => filter != old.filter;
}

class _InvoiceTile extends StatelessWidget {
  final InvoiceModel invoice;

  const _InvoiceTile({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final (color, icon, bgColor, badgeColor) = _statusStyle();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.separator.withOpacity(0.15)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(invoice.invoiceNumber ?? invoice.id,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text('₦${invoice.amount.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(_periodText(),
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        invoice.status.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (invoice.dueDate != null)
                      Text(
                        _dueDateText(),
                        style: GoogleFonts.inter(fontSize: 10, color: invoice.isOverdue ? AppColors.error : AppColors.textQuaternary, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, Color, Color) _statusStyle() {
    if (invoice.isPaid) {
      return (AppColors.success, Icons.check_circle_rounded, const Color(0xFFE8F5E9), AppColors.success.withOpacity(0.12));
    }
    if (invoice.isOverdue) {
      return (AppColors.error, Icons.receipt_long_rounded, const Color(0xFFFFEBEE), AppColors.error.withOpacity(0.12));
    }
    return (AppColors.warning, Icons.schedule_rounded, AppColors.accentLight, AppColors.warning.withOpacity(0.12));
  }

  String _periodText() {
    final d = invoice.createdAt;
    return d != null ? '${d.month}/${d.day}/${d.year}' : '';
  }

  String _dueDateText() {
    if (invoice.isPaid) {
      final p = invoice.paidAt;
      if (p != null) return 'Paid on ${p.month}/${p.day}';
    }
    final due = invoice.dueDate;
    if (due != null) return 'Due ${due.month}/${due.day}';
    return '';
  }
}
