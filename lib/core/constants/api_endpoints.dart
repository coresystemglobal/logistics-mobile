class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String getMe = '/auth/me';
  static const String refreshToken = '/auth/refresh';
  static const String registerCustomer = '/auth/register/customer';
  static const String registerRider = '/auth/register/rider';
  static const String registerBusiness = '/auth/register/business';
  static const String passwordResetRequest = '/auth/password/reset-request';
  static const String passwordResetConfirm = '/auth/password/reset-confirm';
  static const String updatePassword = '/auth/password/update';
  static const String updateMe = '/auth/me';
  static const String updateProfilePhoto = '/auth/me/profile-photo';

  // Packages
  static const String packages = '/packages';
  static String trackPackage(String trackingNumber) =>
      '/packages/track/$trackingNumber';
  static String packageByTracking(String trackingNumber) =>
      '/packages/$trackingNumber';
  static String cancelPackage(String id) => '/packages/$id/cancel';
  static String claimPackage(String trackingNumber) =>
      '/packages/$trackingNumber/claim';
  static String packageById(String id) => '/packages/by-id/$id';
  static String confirmPickup(String id) => '/packages/$id/confirm-pickup';
  static String confirmDelivery(String id) => '/packages/$id/confirm-delivery';

  // Riders
  static const String riderJobs = '/riders/jobs';
  static const String riderProfile = '/riders/profile';
  static const String riderLocation = '/riders/location';
  static const String riderStatus = '/riders/status';
  static const String riderAvailability = '/riders/availability';
  static const String riderEligibility = '/riders/eligibility';

  // Matching
  static String courierLocation(String courierId) =>
      '/matching/couriers/$courierId/location';
  static String courierStatus(String courierId) =>
      '/matching/couriers/$courierId/status';
  static String courierState(String courierId) =>
      '/matching/couriers/$courierId/state';
  static const String findCouriers = '/matching/find-couriers/by-address';
  static const String requestDelivery = '/matching/request-delivery';
  static String acceptOffer(String courierId, String requestId) =>
      '/matching/offers/$courierId/$requestId/accept';
  static String rejectOffer(String courierId, String requestId) =>
      '/matching/offers/$courierId/$requestId/reject';

  // Scheduling
  static const String scheduleDelivery = '/scheduling/schedule';

  // Wallet
  static const String walletBalance = '/wallet/balance';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletBankAccount = '/wallet/bank-account';
  static const String walletFundInitialize = '/wallet/fund/initialize';
  static const String walletFundVerify = '/wallet/fund/verify';
  static const String walletPayForDelivery = '/wallet/pay-for-delivery';
  static String initializeTransfer(String packageId) => '/packages/$packageId/initialize-transfer';

  // Dispatch
  static const String scheduleBackgroundSearch = '/packages/schedule-search';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationPreferences = '/notifications/preferences';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Messages (per-package chat)
  static String packageMessages(String packageId) =>
      '/packages/$packageId/messages';
  static String packageMessagesUnread(String packageId) =>
      '/packages/$packageId/messages/unread';

  // Quotes
  static const String quotes = '/quotes';
  static const String myQuotes = '/quotes/user/my-quotes';
  static String quoteByCode(String code) => '/quotes/$code';

  // Addresses
  static const String addresses = '/addresses';
  static const String defaultAddress = '/addresses/default';
  static String updateAddress(String id) => '/addresses/$id';
  static String setDefaultAddress(String id) => '/addresses/$id/default';
  static String deleteAddress(String id) => '/addresses/$id';

  // Ratings
  static const String ratings = '/ratings';
  static String riderRatings(String riderId) => '/ratings/rider/$riderId';
  static String riderRatingStats(String riderId) =>
      '/ratings/rider/$riderId/stats';

  // Businesses
  static const String businesses = '/businesses';
  static String businessById(String id) => '/businesses/$id';

  // Invoices
  static const String invoices = '/invoices';
  static const String generateInvoice = '/invoices/generate';
  static const String overdueInvoices = '/invoices/overdue';
  static String markInvoicePaid(String id) => '/invoices/$id/paid';

  // Referrals
  static const String referralCode = '/referrals/my-code';
  static const String applyReferral = '/referrals/apply';
  static const String updateReferralCode = '/referrals/update-code';
  static const String referralStats = '/referrals/stats';

  // Promotions
  static const String promotions = '/promotions';
  static const String redeemPromotion = '/promotions/redeem';
  static String promotionById(String id) => '/promotions/$id';
  static String promotionUsages(String id) => '/promotions/$id/usages';

  // Verification
  static const String verifyEmail = '/verification/verify-email';
  static const String verifyPhone = '/verification/verify-phone';
  static const String resendEmailVerification = '/verification/resend-email';
  static const String resendPhoneVerification = '/verification/resend-phone';
  static String triggerDeliveryCode(String packageId) =>
      '/verification/trigger-delivery-code/$packageId';

  // Dashboard
  static const String dashboardRider = '/dashboard/rider';
  static const String dashboardManager = '/dashboard/manager';
  static const String dashboardManagerRiders = '/dashboard/manager/riders';
  static const String dashboardManagerPackages = '/dashboard/manager/packages';

  // Legal
  static const String faq = '/legal/faq';
  static const String terms = '/legal/terms';
  static const String commissionPolicy = '/legal/commission-policy';

  // Service areas
  static const String serviceCities = '/service-areas/cities';
  static const String checkCoverage = '/service-areas/check';

  // Waitlist
  static const String waitlist = '/waitlist';

  // Upload
  static const String upload = '/upload';

  // Pricing
  static const String calculatePrice = '/pricing/calculate';
  static const String fuelPrice = '/fuel-price';
}
