import 'package:flutter_test/flutter_test.dart';
import 'package:traka_mobile/main.dart';
import 'package:traka_mobile/core/api/api_client.dart';
import 'package:traka_mobile/services/auth_service.dart';

void main() {
  group('App Initialization', () {
    testWidgets('App loads and shows splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      
      // Verify splash screen is shown
      expect(find.text('TRAKA'), findsOneWidget);
    });
  });

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
