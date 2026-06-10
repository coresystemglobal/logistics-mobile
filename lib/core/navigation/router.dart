import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/welcome_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_type_screen.dart';
import '../../screens/auth/register_customer_screen.dart';
import '../../screens/auth/register_rider_screen.dart';
import '../../screens/auth/register_business_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/email_verification_screen.dart';
import '../../screens/customer/customer_shell.dart';
import '../../screens/customer/customer_home_screen.dart';
import '../../screens/customer/book_delivery_screen.dart';
import '../../screens/customer/booking_confirmation_screen.dart';
import '../../screens/customer/tracking_screen.dart';
import '../../screens/customer/order_history_screen.dart';
import '../../screens/customer/customer_profile_screen.dart';
import '../../screens/customer/wallet_screen.dart';
import '../../screens/rider/rider_shell.dart';
import '../../screens/rider/available_jobs_screen.dart';
import '../../screens/rider/active_delivery_screen.dart';
import '../../screens/rider/earnings_screen.dart';
import '../../screens/rider/rider_profile_screen.dart';
import '../../screens/shared/notifications_screen.dart';
import '../../screens/shared/package_chat_screen.dart';
import '../../screens/shared/faq_screen.dart';
import '../../screens/business/business_shell.dart';
import '../../screens/business/business_dashboard_screen.dart';
import '../../screens/business/business_packages_screen.dart';
import '../../screens/business/bulk_shipment_screen.dart';
import '../../screens/business/invoices_screen.dart';
import '../../screens/shared/ratings_screen.dart';
import '../../screens/customer/quote_screen.dart';
import '../../screens/customer/fund_wallet_screen.dart';
import '../../screens/customer/transaction_detail_screen.dart';
import '../../screens/customer/live_tracking_screen.dart';
import '../../screens/customer/delivery_complete_screen.dart';
import '../../screens/customer/transaction_history_screen.dart';
import '../../screens/customer/change_password_screen.dart';
import '../../screens/customer/referral_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final status = authState.status;
      final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation == '/';

      if (status == AuthStatus.unknown) return '/';

      if (status == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/auth/welcome';
      }

      if (status == AuthStatus.authenticated && isAuthRoute) {
        if (authState.isRider) return '/rider/jobs';
        if (authState.user?.isBusinessOwner == true) return '/business/dashboard';
        return '/customer/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(path: '/auth/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterTypeScreen()),
      GoRoute(path: '/auth/register/customer', builder: (_, __) => const RegisterCustomerScreen()),
      GoRoute(path: '/auth/register/rider', builder: (_, __) => const RegisterRiderScreen()),
      GoRoute(path: '/auth/register/business', builder: (_, __) => const RegisterBusinessScreen()),
      GoRoute(path: '/auth/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/auth/verify-email',
        builder: (context, state) => EmailVerificationScreen(
          email: state.uri.queryParameters['email'],
        ),
      ),

      // Customer shell (wallet & profile tabs inside shell)
      ShellRoute(
        builder: (context, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(path: '/customer/home', builder: (_, __) => const CustomerHomeScreen()),
          GoRoute(path: '/customer/history', builder: (_, __) => const OrderHistoryScreen()),
          GoRoute(path: '/customer/wallet', builder: (_, __) => const WalletScreen()),
          GoRoute(path: '/customer/profile', builder: (_, __) => const CustomerProfileScreen()),
        ],
      ),

      // Customer routes outside shell
      GoRoute(path: '/customer/book', builder: (_, __) => const BookDeliveryScreen()),
      GoRoute(
        path: '/customer/booking-confirm/:trackingNumber',
        builder: (context, state) => BookingConfirmationScreen(
          trackingNumber: state.pathParameters['trackingNumber']!,
        ),
      ),
      GoRoute(
        path: '/customer/track/:trackingNumber',
        builder: (context, state) => TrackingScreen(
          trackingNumber: state.pathParameters['trackingNumber']!,
        ),
      ),
      GoRoute(
        path: '/customer/chat/:packageId',
        builder: (context, state) => PackageChatScreen(
          packageId: state.pathParameters['packageId']!,
        ),
      ),
      GoRoute(path: '/customer/fund-wallet', builder: (_, __) => const FundWalletScreen()),
      GoRoute(path: '/customer/transactions', builder: (_, __) => const TransactionHistoryScreen()),
      GoRoute(path: '/customer/change-password', builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: '/customer/referral', builder: (_, __) => const ReferralScreen()),
      GoRoute(path: '/customer/quote', builder: (_, __) => const QuoteScreen()),
      GoRoute(
        path: '/customer/transaction/:id',
        builder: (context, state) => TransactionDetailScreen(
          transactionId: state.pathParameters['id'],
          type: state.uri.queryParameters['type'],
          amount: double.tryParse(state.uri.queryParameters['amount'] ?? ''),
          status: state.uri.queryParameters['status'],
          method: state.uri.queryParameters['method'],
          reference: state.uri.queryParameters['reference'],
          narration: state.uri.queryParameters['narration'],
          date: state.uri.queryParameters['date'],
          balanceAfter: double.tryParse(state.uri.queryParameters['balanceAfter'] ?? ''),
          packageId: state.uri.queryParameters['packageId'],
        ),
      ),
      GoRoute(
        path: '/customer/live-tracking/:packageId',
        builder: (context, state) => LiveTrackingScreen(
          packageId: state.pathParameters['packageId']!,
        ),
      ),
      GoRoute(
        path: '/customer/delivery-complete/:packageId',
        builder: (context, state) => DeliveryCompleteScreen(
          packageId: state.pathParameters['packageId']!,
          riderId: state.uri.queryParameters['riderId'] ?? '',
          riderName: state.uri.queryParameters['riderName'] ?? 'Rider',
          riderRating: double.tryParse(state.uri.queryParameters['riderRating'] ?? '') ?? 0,
          recipientName: state.uri.queryParameters['recipientName'] ?? '',
          deliveryCode: state.uri.queryParameters['code'] ?? '',
          deliveryTime: state.uri.queryParameters['time'] ?? '',
        ),
      ),
      GoRoute(path: '/business/bulk-shipment', builder: (_, __) => const BulkShipmentScreen()),
      GoRoute(
        path: '/ratings/:riderId',
        builder: (context, state) => RatingsScreen(
          riderId: state.pathParameters['riderId']!,
          riderName: state.uri.queryParameters['name'],
        ),
      ),
      GoRoute(path: '/faq', builder: (_, __) => const FaqScreen()),
      GoRoute(path: '/business/invoices', builder: (_, __) => const InvoicesScreen()),

      // Rider shell
      ShellRoute(
        builder: (context, state, child) => RiderShell(child: child),
        routes: [
          GoRoute(path: '/rider/jobs', builder: (_, __) => const AvailableJobsScreen()),
          GoRoute(path: '/rider/earnings', builder: (_, __) => const EarningsScreen()),
          GoRoute(path: '/rider/profile', builder: (_, __) => const RiderProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/rider/active/:packageId',
        builder: (context, state) => ActiveDeliveryScreen(
          packageId: state.pathParameters['packageId']!,
        ),
      ),

      // Business shell
      ShellRoute(
        builder: (context, state, child) => BusinessShell(child: child),
        routes: [
          GoRoute(path: '/business/dashboard', builder: (_, __) => const BusinessDashboardScreen()),
          GoRoute(path: '/business/packages', builder: (_, __) => const BusinessPackagesScreen()),
          GoRoute(path: '/business/profile', builder: (_, __) => const CustomerProfileScreen()),
        ],
      ),

      // Shared
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    ],
  );
});

