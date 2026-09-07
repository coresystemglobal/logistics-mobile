/// Identifies this application to the API.
///
/// Sent as the [header] on every request. The server validates it against an
/// allowlist and attaches it to payment provider metadata, so transactions can
/// be attributed to the application that started them. A value the server does
/// not recognise is not rejected — it is recorded as 'unknown' — so [appId]
/// must stay in step with ALLOWED_APP_IDS on the server.
///
/// Deliberately a compile-time constant rather than a lookup via
/// package_info_plus: the request interceptor is synchronous, and a flavor
/// suffix on the real bundle id would silently fall off the allowlist.
class AppIdentity {
  const AppIdentity._();

  /// Matches the bundle id of the shipped artifact.
  static const String appId = 'com.opright.logistics';

  static const String header = 'X-App-Id';
}
