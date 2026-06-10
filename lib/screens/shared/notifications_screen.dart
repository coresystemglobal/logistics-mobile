import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';

final _notificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>(
  (ref) => NotificationService().getNotifications(),
);

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _activeFilter = 0;
  static const _filters = ['All', 'Deliveries', 'Wallet', 'Promotions'];

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(_notificationsProvider);

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textPrimary,
                    onPressed: () => context.pop(),
                  ),
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

            // Title + Mark all read
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GestureDetector(
                      onTap: () async {
                        await NotificationService().markAllAsRead();
                        ref.invalidate(_notificationsProvider);
                      },
                      child: Text(
                        'Mark all read',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final active = _activeFilter == i;
                  return GestureDetector(
                    onTap: () => setState(() => _activeFilter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.accentLight : AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: active ? AppColors.accent : Colors.transparent,
                          width: active ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        _filters[i],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          color: active ? AppColors.accent : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Notifications list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(_notificationsProvider.future),
                color: AppColors.accent,
                child: notificationsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return _EmptyState();
                    }
                    return _NotificationList(notifications: notifications);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.accentLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.accent,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'All caught up!',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'No notifications yet',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;
  const _NotificationList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    // Group into Today / Yesterday / Earlier
    final today = <NotificationModel>[];
    final yesterday = <NotificationModel>[];
    final earlier = <NotificationModel>[];
    final now = DateTime.now();
    for (final n in notifications) {
      final d = n.createdAt;
      if (d == null) {
        today.add(n);
      } else {
        final diff = now.difference(d).inDays;
        if (diff == 0) {
          today.add(n);
        } else if (diff == 1) {
          yesterday.add(n);
        } else {
          earlier.add(n);
        }
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (today.isNotEmpty) ...[
          _GroupHeader(label: 'Today'),
          ...today.map((n) => _NotificationTile(notification: n)),
        ],
        if (yesterday.isNotEmpty) ...[
          _GroupHeader(label: 'Yesterday'),
          ...yesterday.map((n) => _NotificationTile(notification: n)),
        ],
        if (earlier.isNotEmpty) ...[
          _GroupHeader(label: 'Earlier'),
          ...earlier.map((n) => _NotificationTile(notification: n)),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.bgSecondary,
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textQuaternary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  Color get _iconColor {
    switch (notification.type.toUpperCase()) {
      case 'PAYMENT':
        return AppColors.success;
      case 'PROMOTION':
        return AppColors.iosBlue;
      default:
        return AppColors.accent;
    }
  }

  IconData get _icon {
    switch (notification.type.toUpperCase()) {
      case 'DELIVERY_UPDATE':
        return Icons.local_shipping_rounded;
      case 'PAYMENT':
        return Icons.account_balance_wallet_rounded;
      case 'MESSAGE':
        return Icons.chat_bubble_rounded;
      case 'PROMOTION':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return GestureDetector(
      onTap: () {
        if (unread) NotificationService().markAsRead(notification.id);
      },
      child: Container(
        color: unread ? const Color(0xFFFFF9F6) : AppColors.bgPrimary,
        child: Stack(
          children: [
            // Unread left bar
            if (unread)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: AppColors.accent),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_icon, color: _iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: unread
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(notification.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textQuaternary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom divider
            Positioned(
              left: 70,
              right: 0,
              bottom: 0,
              child: Divider(
                height: 0.5,
                thickness: 0.5,
                color: AppColors.separator.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
