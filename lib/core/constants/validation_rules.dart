/// Client-side mirrors of the rules the API enforces.
///
/// These exist so a form rejects input the server would reject anyway, giving
/// immediate feedback instead of a round trip. They must never be *stricter*
/// than the server: a form that demands more than the API does refuses valid
/// input for no reason, and the message it shows is a promise the system does
/// not actually make.
///
/// Source of truth: logistics-server/src/utils/validators.ts
class ValidationRules {
  /// Mirrors MIN_PASSWORD_LENGTH. Applies wherever a password is *set*
  /// (registration, reset, change) — never to login, where the server stays
  /// permissive so accounts created under older rules can still sign in.
  static const int minPasswordLength = 8;

  /// Mirrors the `min(2)` on first_name and surname.
  static const int minNameLength = 2;

  /// Verification codes are six digits.
  static const int otpLength = 6;

  static String passwordTooShort() =>
      'Password must be at least $minPasswordLength characters';
}
