import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class CustomerShell extends StatelessWidget {
  final Widget child;
  const CustomerShell({super.key, required this.child});

  int _currentIndex(String location) {
    if (location.startsWith('/customer/history')) return 1;
    if (location.startsWith('/customer/wallet')) return 3;
    if (location.startsWith('/customer/profile')) return 4;
    if (location.startsWith('/notifications')) return 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(location);

    return Scaffold(
      body: child,
      extendBody: true,
      floatingActionButton: _BookFab(
        onTap: () => context.push('/customer/book'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _OprightBottomBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/customer/home');
            case 1:
              context.go('/customer/history');
            case 2:
              break; // handled by FAB
            case 3:
              context.go('/customer/wallet');
            case 4:
              context.go('/customer/profile');
          }
        },
      ),
    );
  }
}

class _OprightBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _OprightBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.bgPrimary.withValues(alpha: 0.92),
      elevation: 0,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0x1AC6C6C8),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.location_searching_rounded,
              activeIcon: Icons.location_searching_rounded,
              label: 'Track',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 56), // space for FAB
            _NavItem(
              icon: Icons.account_balance_wallet_outlined,
              activeIcon: Icons.account_balance_wallet_rounded,
              label: 'Wallet',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
              isActive: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 26,
              color: isActive ? AppColors.accent : AppColors.textQuaternary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive ? AppColors.accent : AppColors.textQuaternary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookFab extends StatelessWidget {
  final VoidCallback onTap;

  const _BookFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Book',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textQuaternary,
            ),
          ),
        ],
      ),
    );
  }
}
