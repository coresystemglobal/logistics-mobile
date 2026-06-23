import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/api/token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        user = null,
        error = null;

  const AuthState.authenticated(UserModel this.user)
      : status = AuthStatus.authenticated,
        error = null;

  const AuthState.unauthenticated([this.error])
      : status = AuthStatus.unauthenticated,
        user = null;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isRider => user?.isRider ?? false;
  bool get isCustomer => user?.isUser ?? false;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState.unknown()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final hasTokens = await TokenStorage.hasTokens();
      if (!hasTokens) {
        state = const AuthState.unauthenticated();
        return;
      }
      final user = await _authService.getMe();
      state = AuthState.authenticated(user);
    } catch (_) {
      await TokenStorage.clearTokens();
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.login(email: email, password: password);
      final user = await _authService.getMe();
      state = AuthState.authenticated(user);
    } catch (e, stack) {
      debugPrint('[AUTH] Login failed: $e');
      debugPrint('[AUTH] Stack: $stack');
      state = AuthState.unauthenticated(e.toString());
      rethrow;
    }
  }

  Future<void> registerCustomer({
    required String firstName,
    required String surname,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _authService.registerCustomer(
      firstName: firstName,
      surname: surname,
      email: email,
      phone: phone,
      password: password,
    );
    // Tokens are saved but state stays unauthenticated until email is verified.
  }

  Future<void> registerRider({
    required String firstName,
    required String surname,
    required String email,
    required String phone,
    required String password,
    required String vehicleType,
    String? referralCode,
    String? licenseNumber,
    String? vehiclePlate,
  }) async {
    await _authService.registerRider(
      firstName: firstName,
      surname: surname,
      email: email,
      phone: phone,
      password: password,
      vehicleType: vehicleType,
      referralCode: referralCode,
      licenseNumber: licenseNumber,
      vehiclePlate: vehiclePlate,
    );
    // Tokens are saved but state stays unauthenticated until email is verified.
  }

  Future<void> registerBusiness({
    required String businessName,
    required String contactPerson,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    await _authService.registerBusiness(
      businessName: businessName,
      contactPerson: contactPerson,
      email: email,
      phone: phone,
      address: address,
      password: password,
    );
    // Tokens are saved but state stays unauthenticated until email is verified.
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState.unauthenticated();
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authService.getMe();
      state = AuthState.authenticated(user);
    } catch (_) {}
  }

  Future<void> updateProfile({
    String? firstName,
    String? surname,
    String? phone,
  }) async {
    await _authService.updateProfile(
      firstName: firstName,
      surname: surname,
      phone: phone,
    );
    await refreshUser();
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
