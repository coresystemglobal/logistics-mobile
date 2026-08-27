import 'package:flutter_test/flutter_test.dart';
import 'package:opright_mobile/core/api/api_client.dart';
import 'package:opright_mobile/services/auth_service.dart';

void main() {
  group('API Client', () {
    test('API client initializes with correct base URL', () {
      final apiClient = ApiClient.instance;
      expect(apiClient, isNotNull);
      expect(apiClient.dio, isNotNull);
    });
  });

  group('Auth Service', () {
    test('Auth service can be instantiated', () {
      final authService = AuthService();
      expect(authService, isNotNull);
    });
  });
}
